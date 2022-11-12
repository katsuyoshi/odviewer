require 'nokogiri'
require 'open-uri'
require 'json'

root_dir = File.dirname(File.dirname(__FILE__))

doc = Nokogiri::HTML(URI.open("https://www.city.daisen.lg.jp/categories/zokusei/opendatedoc/"))
list = doc.search('.title_link').map do |e|
  e.search('a').map{|e1| [e1['href'], e1.text]}.first
end

list = list.map do |l|
  doc = Nokogiri::HTML(URI.open("https://www.city.daisen.lg.jp#{l.first}"))
  e = doc.css('a.iconFile.iconCsv').first
  {
    url: "https://www.city.daisen.lg.jp#{l.first}/#{e['href']}",
    name: l.last,
  }
end


config_path = File.join(root_dir, 'dim.json')
config = JSON.parse(File.read(config_path))
config['contents'] = list.map do |l|
  {
    'url' => l[:url],
    'name' => l[:name],
    'catalogUrl' => nil,
    'catalogResourceId' => nil,
    'postProcesses' => [ 'encode UTF-8' ],
    'headers' => {},
  }
end

File.write(config_path, JSON.pretty_generate(config))


__END__

"url": "https://www.city.daisen.lg.jp/docs/2021120600022/file_contents/01_.csv",
"name": "国保加入世帯の状況",
"catalogUrl": null,
"catalogResourceId": null,
"postProcesses": [
  "encode UTF-8"
],
"headers": {}






p list
