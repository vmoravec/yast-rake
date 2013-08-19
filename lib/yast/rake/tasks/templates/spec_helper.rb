require 'minitest/autorun'
require 'minitest/spec'
require 'yast'

# Use `require_relative "spec_helper"` on top of your spec files to be able to
# run them separately with command `ruby spec/some_spec.rb`
# Use `rake spec` to run the whole testsuite.

if __FILE__ == $0
  $LOAD_PATH.unshift('lib', 'spec')
  Dir.glob('./spec/**/*_spec.rb') { |f| require f }
end
