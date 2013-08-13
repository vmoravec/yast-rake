require 'pathname'
require 'yast/rake/version'
require 'yast/rake/config'
require 'yast/rake/tasks'

module Yast
  module Rake

    def rake
      @rake ||= Config
    end

  end
end

# Extend the main object with rake method to work with it
# directly from the Rakefile
self.extend Yast::Rake

# Import the default built-in tasks
Yast::Rake::Tasks.import_default_tasks

# Load custom configuration from path rake/config
Yast::Rake::Config.load_custom_config_modules

# Import the custom tasks if there are any
# Inspected dirs: [ tasks/, rake/tasks/ ]
Yast::Rake::Tasks.import_custom_tasks(rake.config.root)
