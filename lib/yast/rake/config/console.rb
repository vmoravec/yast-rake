module Yast::Rake::Config
  module Console
    attr_reader :proc

    def setup
      @proc = Proc.new {}
    end
  end
end
