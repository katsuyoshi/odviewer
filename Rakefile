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

  desc 'remove data_files'
  task :clean do
    d = './data_files'
    rm_r d if File.exist? d
  end

  desc 'update config/dim.json'
  task :setup_config do |t|
    system "ruby ./scripts/mkconfig.rb"
  end

  desc 'update dim.json'
  task :setup do |t|
    system "dim install -F -f config/dim.json"
    system "ruby ./scripts/mkdataset.rb"
  end

  desc 'update data'
  task :update do |t|
    rm 'dim-lock.json'
    system "dim install -F"
  end

  desc 'publish data'
  task :publish do |t|
    system "ruby ./scripts/publish_data.rb"
  end

  desc 'clean and download all data'
  task :reload_all => [:clean, :setup_config, :setup, :update, :publish]

end