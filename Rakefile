require 'rake'
require 'rake/testtask'
require 'rdoc/task'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the xero gateway.'
Rake::TestTask.new(:test) do |t|
  t.libs << '.'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

