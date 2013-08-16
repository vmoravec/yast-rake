desc "Start irb session with yast/rake loaded"
task :console do
  require 'irb'

  # avoiding exception "No such file or directory - console"
  ARGV.clear

  # By default the proc is an empty block;
  # Use it if you want to execute some code before getting the irb session active;
  # Typical use case is loading some specific code to avoid repeated writing ;)
  rake.config.console.proc.call

  IRB.start
end

#TODO add rake.config.console.reload! method or rake.reload!
