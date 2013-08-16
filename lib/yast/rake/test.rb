require 'forwardable'

module Yast
  module Rake
    module Config
      module Test
        class << self
          extend Forwardable

          def_delegators :@config, :register, :update

          attr_reader :config

          def config= config_proxy
            @config  = config_proxy
            @verbose = config_proxy.verbose
            @trace   = config_proxy.trace
            @config
          end

          def test
            self
          end

          def method_missing method_name
            if method_name == :config
              STDERR.puts "'rake.config' namespace is not available in test extension. " +
                          "Use 'rake.test.config' instead."
            else
              super
            end
          end
        end
      end

      def self.load_test_module
        Test.config = Proxy.new
      end

      def self.extend_top_level main
        if main.respond_to?(:rake)
          main.rake.define_singleton_method :test do
            Test
          end
        else
          main.define_singleton_method :rake do
            Test
          end
        end
      end
    end
  end
end

# Extend main object with new `rake.test` method
# Or extend the existing `rake` helper with `test` namespace

Yast::Rake::Config.extend_top_level self

# load the Config module to reuse its definition for our Test module
require 'yast/rake/config'

Yast::Rake::Config.load_test_module
