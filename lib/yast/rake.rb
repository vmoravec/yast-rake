require 'pathname'
require 'yast/rake/version'
require 'yast/rake/config'
require 'yast/rake/tasks'

module Yast
  module Rake

    def rake
      Yast::Rake::Config
    end

  end
end

# Remove the method main#rake if it exists.
# The theory behind removing it is following:
# require 'yast/rake' should remove `rake` method from the main scope in case
# it was defined before by yast/rake/test.
# Practicaly it means that 'yast/rake/test' is adaptive while 'yast/rake' not and
self.singleton_class.__send__(:remove_method, :rake) if self.respond_to?(:rake)

# Extend the main object with rake method to work with it
# directly from the Rakefile
self.extend Yast::Rake

# Load the default configuration
Yast::Rake::Config.load_default_config_modules

# Import the default built-in tasks
# Custom tasks will be loaded after the custom config modules are loaded
Yast::Rake::Tasks.import_default_tasks

# Load custom configuration from path rake/config
# When you are looking where the default modules are being loaded
# then look at the bottom of yast/rake/config
Yast::Rake::Config.load_custom_config_modules

# Import the custom tasks if there are any
# Inspected dirs: [ tasks/, rake/tasks/ ]
Yast::Rake::Tasks.import_custom_tasks(rake.config.root)
