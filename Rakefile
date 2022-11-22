require "rake/testtask"
require 'fileutils'

include FileUtils

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test


namespace :data do

  desc 'clean data'
  task :clean do
    rm_r './data_files'
  end

  desc 'upate dim.json'
  task :setup do |t|
    system "dim install -F -f config/dim.json"
    system "ruby ./scripts/mkdimjson.rb"
  end

  desc 'update data'
  task :update do |t|
    system "dim install -F"
  end


end