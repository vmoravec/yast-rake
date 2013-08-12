# Yast::Rake

Collection of common useful Rake tasks and configuration extension

## Installation

This code is not available as a rpm package nor a ruby gem yet, below
you find more details on how to try it out from within a git repo.

1. `git clone git@github.com:yast/yast-rake.git`
2. `cd yast-rake`
3. `rake install` or `sudo rake install`
  * please use sudo if you are using system ruby installation;
    for e.g. ruby version manager (RVM) sudo is not used
  * this should install the `yast-rake` gem with dependencies (currently `rake` only)

## Usage

1. `cd some/yast/git/repository/root`
2. `touch Rakefile`
3. `echo 'require "yast/rake"' >> Rakefile`
4. `rake`

You should get a list of all tasks by now, something like this:

  >  rake check:all      # Default task for rake:check  
  >  rake check:package  # Check package code completness  
  >  rake check:syntax   # Check syntax of *.{rb,rake} files  
  >  rake console        # Start irb session with yast/rake loaded  
  >  rake default        # Default task for rake  
  >  rake install        # Install the yast code on the current system  
  >  rake package:check  # Check the package mandatory properties  
  >  rake package:info   # Information about the package  
  >  rake package:init   # Create a new yast package skeleton  
  >  rake test           # Run tests  


## Features

### Tasks

  * predefined common tasks for all yast modules (more to come)
  * defining of custom tasks using the configuration module

### Configuration modules

  * shared helper `rake.config` to be used in `Rakefile` and in tasks
    in top level scope (see Examples)
  * transparent API for defining configuration module namespace
    * ruby module name becomes `rake.config.downcased_module_name`
    * module instance methods available from `rake.config.downcased_module_name.*methods`
    * method `setup` for initializing the configuration
    * `rake.config.register ModuleName` for new config namespace extending
    * `rake.config.update :namespace, ModuleName` for updating existing namespace

#### Examples

  ```ruby
    module Yast::Rake::Config
      module Package
        VERSION_FILE = 'VERSION'

        def version
          File.read(rake.config.root.join(VERSION_FILE)).strip
        end

      end
    end
  ```
* and in `Rakefile`

  ```ruby
    require 'yast/rake'
    require_relative 'rake/config/package' # rake/ dir in root for all rake stuff

    rake.config.register Package

    namespace :package do
      desc "Show package version"
      task :version do
        puts rake.config.package.version
      end
    end
  ```

  You can try it out by running `rake console` which starts an IRB session 
  and loads the Rakefile into the main scope.

  For more real examples please look at the lib/yast/rake/config/*.rb files.


## Todo

  * add comments for Yard
  * add tests (!!) after the design gets approved
  * fix spec file
  * add task for building/installing any yast module
  * identify more useful tasks for obs, git etc.
  * `rake console` does not load the yast code from the git working dir yet
  * loading custom config modules and tasks from specific dir like 
    yast-git-repo/rake/config and yast-git-repo/rake/tasks


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin new-feature`)
5. Create new Pull Request on https://github.com/yast/yast-rake
