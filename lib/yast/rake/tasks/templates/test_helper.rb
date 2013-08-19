require 'minitest/autorun'
require 'yast'

# Use `require_relative "test_helper"` on top of your test files to be able to
# run them separately with command `ruby test/some_test.rb`
# Use `rake test` to run the whole testsuite

if __FILE__ == $0
  $LOAD_PATH.unshift('lib', 'test')
  Dir.glob('./test/**/*_test.rb') { |f| require f }
end

