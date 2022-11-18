# MIT License
# 
# Copyright (c) 2022 Katsuyoshi Ito
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'nokogiri'
require 'open-uri'
require 'json'

root_dir = File.dirname(File.dirname(__FILE__))

doc = Nokogiri::HTML(URI.open("https://www.city.daisen.lg.jp/categories/zokusei/opendatedoc/"))
list = doc.search('.title_link').map do |e|
  e.search('a').map{|e1| [e1['href'], e1.text.strip]}.first
end

list = list.map do |l|
  doc = Nokogiri::HTML(URI.open("https://www.city.daisen.lg.jp#{l.first}"))
  e = doc.css('a.iconFile.iconCsv').first
  {
    url: "https://www.city.daisen.lg.jp#{l.first}#{e['href']}",
    name: l.last.strip,
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
