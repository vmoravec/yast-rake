task(:install).clear

desc "Create a gem file and install it locally"
task :install do
  Rake::Task['build:gem'].invoke
  puts "Installing #{rake.config.gem.name} from #{rake.config.gem.path} ..."
  sh "gem install #{rake.config.gem.path}"
end
