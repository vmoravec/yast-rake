require 'yast/rake/config/base'
require 'yast/rake/config/yast'
require 'yast/rake/config/package'
require 'yast/rake/config/console'
require 'pathname'

module Yast
  module Rake

    module Extension
      def register ; end
      def update ;  end
    end

    module Config


      def self.extended(object)
        object.extend Yast::Rake unless object.respond_to?(:rake)
        object.rake.extend self unless object.rake.respond_to?(:config)
      end

      attr_accessor :verbose, :trace

      def config
        return @config if @config
        @config.extend
        @config ||= ConfigProxy.new
        @verbose = @config.verbose
        @trace   = @config.trace
        @config
      end

      RAKE_CONFIG_DIR = File.join('rake', 'config')


      class ConfigProxy
        attr_reader :config

        include Rake::Extension

        def initialize
          puts "\nSetting up the configuration..." if verbose
          @contexts = Hash.new
          register Config::Base, false
          register Config::Yast
          register Config::Package
          register Config::Console
        end

        def register config_module, keep_module_name=true
          puts "Registering config module #{config_module}" if verbose
          if keep_module_name
            config_name = get_downcased_module_name(config_module)
            remove_config_context(config_name)
            add_config_context(config_name, config_module)
          else
            config_module.public_instance_methods.each do |context_name|
              puts "Registering base config context '#{context_name}'" if verbose
              remove_config_context(context_name)
              add_base_config_context(context_name, config_module)
            end
          end
        end

        def update loaded_module, new_module
          config_name = get_downcased_module_name(loaded_module)
          if @contexts.member?(config_name)
            @contexts[config_name].extend(new_module)
          else
            add_config_context(config_name, new_module)
          end
        end

        def inspect
          "[ #{@contexts.keys.join(', ')} ]"
        end

        def verbose
          defined?(::Rake) ? ::Rake.verbose == true : false
        end

        def trace
          defined?(::Rake) ? ::Rake.application.options.trace == true : false
        end

        private

        def load_custom_config_modules
          puts "Loading custom config modules.." if verbose
          config_dir = config.root.join RAKE_CONFIG_DIR
          Dir.glob("#{config_dir}/*.rb").each {|config_file| require config_file }
        end

        def remove_config_context config_name
          if respond_to?(config_name)
            singleton_class.__send__(:undef_method, config_name)
            @contexts.delete(config_name)
          end
        rescue NameError => e
          puts e.message
        end

        def add_config_context config_name, config_module
          new_context = Context.new(config_name, self).extend(config_module)
          @contexts[config_name] = new_context
          add_context_method(config_name)
          @contexts[config_name]
        end

        SETUP_METHOD = :setup

        def add_base_config_context context_name, config_module
          raise "Method '#{SETUP_METHOD}' not allowed in base context" if context_name == SETUP_METHOD
          new_context = Context.new(context_name, self).extend(config_module)
          @contexts[context_name] = new_context
          add_base_context_method(context_name)
        end

        def add_context_method context_name
          define_singleton_method(context_name) { @contexts[context_name] }
          @contexts[context_name]
        end

        #TODO add arity when sending the method call
        #     currently are supported only methods without args
        def add_base_context_method context_name
          define_singleton_method(context_name) do
            @contexts[context_name].__send__(context_name)
          end
          @contexts[context_name]
        end

        def get_downcased_module_name config_module
          config_module.to_s
          .split("::").last
          .split(/(?=[A-Z])/)
          .map(&:downcase).join('_').to_sym
        end

        def to_ary
          @contexts.keys
        end

        def method_missing name, *args, &block
          super
        rescue => e
          puts "rake.config does not know about context '#{name}'"
          puts "Registered contexts: #{@contexts.keys.join ', '}"
          puts e.backtrace if Config.trace
        end

        class Context
          attr_reader :rake, :context_name, :errors

          def initialize context_name, rake
            @rake   = rake
            @errors = []
            @context_name = context_name
            @config_methods = []
            @errors_reported = false
          end

          def extend config_module
            make_setup_method_private(config_module)
            config_module.public_instance_methods.each do |method_name|
              @config_methods.push(method_name) unless @config_methods.include?(method_name)
            end
            super           # keep the Object.extend functionality
            run_setup       # call the setup method from config module
            report_errors   # if setup collected errors, show them now
            self            # return the extended context
          end

          def inspect
            "[ #{@config_methods.sort.join(', ')} ]"
          end

          def report_errors force_report=false
            if force_report || !@errors_reported
              errors.each do |err_message|
                STDERR.puts("#{context_name.capitalize}: #{err_message}")
                set_exit_code_to_one unless @exit_code
              end
            end
            @errors_reported = true
          end

          def check
            report_errors
          end

          def check!
            report_errors
            Kernel.abort "Found #{errors.size} #{errors.one? ? 'error' : 'errors'}."
          end

          private

          def make_setup_method_private config_module
            if config_module.public_instance_methods.include?(SETUP_METHOD)
              config_module.__send__(:private, SETUP_METHOD)
            end
          end

          def run_setup
            __send__(SETUP_METHOD) if respond_to?(SETUP_METHOD, true)
          end

          def set_exit_code_to_one
            puts "Setting exit code to 1" if rake.verbose
            @exit_code = 1
            Kernel.at_exit { exit @exit_code }
          end

        end # Context
      end # Proxy
    end # Config
  end # Rake
end # Yast

