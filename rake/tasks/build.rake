namespace :build do

  package = rake.config.package

  desc "Create a gem for yast-rake"
  task :gem do
    gem_spec = 'yast-rake.gemspec'
    gem_name = "#{package.name}-#{package.version}.gem"
    sh "gem build #{gem_spec}"
    install gem_name, package.dir
    puts "Gem file is available in #{package.dir.join gem_name}"
    rm gem_name
  end

  #TODO
  desc "Create an rpm package from gem"
  task :package do
    # implement creating the rpm package
  end
end
