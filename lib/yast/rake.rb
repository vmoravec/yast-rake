require 'pathname'
require 'yast/rake/version'
require 'yast/rake/config'
require 'yast/rake/tasks'

module Yast
  module Rake

    def rake
      self
    end

    # Remove the method main#rake if it exists.
    # You should require 'yast/rake' only if you need to work with ruby Rake, like in a Rakefile
    # Practicaly it means that 'yast/rake/test' is adaptive while 'yast/rake' not and
    def self.extended(main)
      main.singleton_class.__send__(:remove_method, :rake) if self.respond_to?(:rake)
    end

  end
end

# Extend the main object with rake to to get rake object to main in Rakefile
self.extend Yast::Rake

# Add rake.config
# create a callback in Config.self_extended and check the remote self for some stuff
rake.extend Yast::Rake::Config # => check whether rake in main is defined and if not
                               # => create it on some object, either main or any ohter object
# Adda rake.command
rake.extend Yast::Rake::Command
# rake.config.load_defaults
# rake.command.load_defaults
# rake.config.load_custom_modules
# rake.tasks.load_defaults
# rake.tasks.load_tasks

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
