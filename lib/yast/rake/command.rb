require 'yast/rake/context'

module Yast
  module Rake
    module Command
      LOCAL_COMMAND_DIR = File.join('rake', 'command')

      extend Context

      attr_accessor :verbose, :trace

      def command
        Command.get_module_context
      end

    end
  end
end
