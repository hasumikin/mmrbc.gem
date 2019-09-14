require "bundler/gem_tasks"
require "rake/testtask"

desc "make sheared libraries"
task :make do
  Dir.chdir("ext/mrbcc") do
    system "make"
  end
end

desc "make clean"
task :make_clean do
  Dir.chdir("ext/mrbcc") do
    system "make clean"
  end
end

desc "Run tests"
Rake::TestTask.new(:run_test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = Dir["test/**/*_test.rb"]
  t.verbose = true
end

task test: [:make, :run_test]

task default: :test
