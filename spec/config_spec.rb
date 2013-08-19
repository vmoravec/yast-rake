require_relative 'spec_helper'

require 'yast/rake/config'

class TestRake
  def initialize
    extend Yast::Rake::Config
  end
end

puts TestRake.new.config.root


describe 'rake.config' do
  before do
    @rake = TestRake.new
  end

  after do
    @rake = nil
  end

  it "allows access to default configuration modules" do
    #@rake.config.must_respond_to :root
    puts @rake.config.respond_to?(:root)
    @rake.config.must_respond_to :yast
    @rake.config.must_respond_to :package
    @rake.config.must_respond_to :console
  end

  it "can extend rake.config by other ruby modules" do
    @rake.config.wont_respond_to :test_config

      module TestConfig
        NAME = 'crazy>path>>>'
        def name
          NAME
        end
      end

    Yast::Rake::Config.register TestConfig
    @rake.config.must_respond_to :test_config
    @rake.config.test_config.must_respond_to :name
    @rake.config.test_config.name.must_equal TestConfig::NAME
  end

  it "can update the rake.config with ruby module" do
    @rake.config.wont_respond_to :test_config
  end
end


