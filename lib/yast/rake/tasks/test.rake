require 'rake/testtask'

src = rake.config.root.join(rake.config.package.files.src_dir)
$LOAD_PATH.unshift(src) unless $LOAD_PATH.include?(src)

Rake::TestTask.new do |t|
  t.libs = [ src ]
  t.test_files = FileList['test/**/*_test.rb']
  t.warning = true
  t.verbose = true
end

