task(:install).clear

desc "Create a gem file and install it locally"
task :install do
  Rake::Task['build:gem'].invoke
  gem = rake.config.gem
  sh "gem install #{gem.path}"
end
