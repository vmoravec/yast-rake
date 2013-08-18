module Yast
  module Rake
    module Extension
      def register
        raise "Missing implementation of method 'register' on extension #{self}"
      end

      def update
        raise "Missing implementation of method 'update' on extension #{self}"
      end

      def method_missing name, *args, &block
        super
      rescue => e
        puts "rake does not know about '#{name}'"
        puts e.message
        puts e.backtrace if self.trace
      end

    end
  end
end
