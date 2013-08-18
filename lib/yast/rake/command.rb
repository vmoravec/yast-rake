module Yast
  module Rake
    module Command
      def self.extended(object)
        object.rake.config
      end
    end
  end
end
