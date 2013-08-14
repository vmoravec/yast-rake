namespace :build do

  package = rake.config.package
  gem     = rake.config.gem

  desc "Create a gem for yast-rake"
  task :gem do
    sh "gem build #{gem.spec}"
    install gem.name, package.dir
    puts "Gem file is available in #{package.dir.join gem.name}"
    rm gem.name
  end

  #TODO
  desc "Create an rpm package from gem"
  task :package do
    # implement creating the rpm package
  end
end
