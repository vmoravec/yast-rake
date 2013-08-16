require_relative 'spec_helper'

require 'yast/rake/test'

#TODO & FIXME
# This does not work as expected
# Implement it somewhere on the Test class to make it reusable for custom config tests
def remove_rake
  self.singleton_class.__send__(:remove_method, :rake) if self.respond_to?(:rake)
end

rake = self.rake

describe 'rake.config' do
  before do
   remove_rake
  end

  after do
    remove_rake
  end

  it "allows access to default configuration modules" do
    rake.test.config.must_respond_to :root
    rake.test.config.must_respond_to :yast
    rake.test.config.must_respond_to :package
    rake.test.config.must_respond_to :console
  end

  it "can extend rake.config by other ruby modules" do
    rake.test.config.wont_respond_to :test_config

      module TestConfig
        NAME = 'crazy>path>>>'
        def name
          NAME
        end
      end

    rake.test.config.register TestConfig
    rake.test.config.must_respond_to :test_config
    rake.test.config.test_config.must_respond_to :name
    rake.test.config.test_config.name.must_equal TestConfig::NAME
  end

  it "can update the rake.config with ruby module" do
    rake.test.config.wont_respond_to :test_config
  end
end


