require "bundler/gem_tasks"
require "rake/testtask"


desc "Run tests"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = Dir["test/**/*_test.rb"]
  t.verbose = true
end

task default: :test
