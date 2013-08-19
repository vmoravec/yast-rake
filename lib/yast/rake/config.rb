require 'yast/rake/config/base'
require 'yast/rake/config/yast'
require 'yast/rake/config/package'
require 'yast/rake/config/console'
require 'yast/rake/context'
require 'pathname'

module Yast
  module Rake
    module Config

      LOCAL_RAKE_CONFIG_DIR = File.join('rake', 'config')

      extend Context

      attr_accessor :verbose, :trace

      def config
        Config.get_module_context
      end

      def self.extended(object)
        register Base, false
        register Yast
        register Package
        register Console
      end

      def self.load_custom_modules
        config_dir = Config.context[:config].root.join(LOCAL_RAKE_CONFIG_DIR)
        Dir.glob("#{config_dir}/*.rb").each {|config_file| require config_file }
      end

    end
  end
end

