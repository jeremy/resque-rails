require 'rubygems'
require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |test|
  test.verbose = true
  test.libs << 'test' << 'lib'
  test.test_files = FileList['test/*_test.rb']
end
