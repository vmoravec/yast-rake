require 'yast/rake/config/base'
require 'yast/rake/config/yast'
require 'yast/rake/config/package'

module Yast
  module Rake
    module Config

      def self.load
        @config ||= Proxy.new
        @verbose = config.verbose?
        @trace   = config.trace?
        self
      end

      def self.config
        @config
      end

      def self.verbose= verbose
        @verbose = verbose
      end

      def self.verbose?
        @verbose
      end

      def self.trace= trace
        @trace = trace
      end

      def self.trace?
        @trace
      end

      def self.method_missing name, *args, &block
        super
      rescue => e
        puts "rake does not know about '#{name}'"
        puts e.message
        puts e.backtrace if self.trace?
      end

      class Proxy
        attr_reader :config

        def initialize
          @config = self
          @contexts = Hash.new
          register Base, false
          register Yast
          register Package
        end

        def register config_module, keep_module_name=true
          if keep_module_name
            config_name = get_downcased_module_name(config_module)
            remove_config_context(config_name)
            add_config_context(config_name, config_module)
          else
            config_module.public_instance_methods.each do |context_name|
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
            add_new_config_context(config_name, new_module)
          end
        end

        def inspect
          @contexts.keys
        end

        def verbose?
          ::Rake.verbose == true
        end

        def trace?
          ::Rake.application.options.trace == true
        end

        private

        def remove_config_context config_name
          if respond_to? config_name
            self.class.__send__(remove_method, config_name)
            @contexts.delete config_name
          end
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
          config_module.to_s.split("::").last.downcase.to_sym
        end

        def method_missing name, *args, &block
          super
        rescue => e
          puts "rake.config does not know about context '#{name}'"
          puts "Registered contexts: #{@contexts.keys.join ', '}"
          puts e.backtrace if Config.trace?
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
            @extended_methods = config_module.public_instance_methods
            @config_methods.concat(@extended_methods)
            super           # keep the Object.extend functionality
            run_setup       # call the setup method from config module
            report_errors   # if setup collected errors, show them now
            self            # return the extended context
          end

          def inspect
            @extended_methods.to_a
          end

          def report_errors force_report=false
            if force_report || !@errors_reported
              errors.each do |err_message|
                STDERR.puts("#{context_name.capitalize}: #{err_message}")
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

        end

      end

    end
  end
end

