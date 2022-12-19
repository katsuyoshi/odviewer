require 'json'
require 'securerandom'
require 'fileutils'

include FileUtils

@root_dir = File.expand_path("../../", __FILE__)

path_map_path = File.join(@root_dir, 'config', 'path_map.json')
path_map = JSON.parse(File.read(path_map_path)) if File.exist? path_map_path
path_map ||= {}

config_path = File.join(@root_dir, 'dim-lock.json')
config = JSON.parse(File.read(config_path))
pathes = config['contents'].map do |c|
  path = c['path']
end

path_map.delete_if{|path| !pathes.include?(path)}
pathes.each do |path|
  path_map[path] ||= File.join(@root_dir, "public", "data_files", "#{SecureRandom.uuid}.csv")
end

mkdir_p File.dirname(path_map[path_map.keys.first])

path_map.each do |src, dst|
  src = File.join(@root_dir, src)
  cp src, dst
end

File.write(path_map_path, JSON.pretty_generate(path_map))
