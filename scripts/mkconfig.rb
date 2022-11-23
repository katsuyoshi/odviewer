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

# It generates '/config/dim.json.'

require 'nokogiri'
require 'open-uri'
require 'csv'
require 'json'

@root_dir = File.expand_path("../../", __FILE__)

@sources = {
  akita_city: 'https://www.city.akita.lg.jp/opendata/1000081/1000082.html',
  daisen_city: 'https://www.city.daisen.lg.jp/docs/2021121400096/',
}


def contents_of_akita_city
  url = @sources[:akita_city]
  doc = Nokogiri::HTML(URI.open(url))
  link = doc.search('.opendata').search('.objectlink').search('.xls').search('a').first
  url2 = url[/.*\//] + link['href']

  {
    "name"              => "ソースリスト/秋田県/秋田市",
    "url"               => url2,
    "catalogUrl"        => nil,
    "catalogResourceId" => nil,
    "postProcesses"     => [
      "xlsx-to-csv",
      "encode UTF-8"
    ],
    "headers"           => {},
  }
end
  
def contents_of_daisen_city
  url = @sources[:daisen_city]
  doc = Nokogiri::HTML(URI.open(url))
  link = doc.css('a.iconFile.iconCsv').first
  url2 = url[/.*\//] + link['href']

  {
    "name"              => "ソースリスト/秋田県/大仙市",
    "url"               => url2,
    "catalogUrl"        => nil,
    "catalogResourceId" => nil,
    "postProcesses"     => [
      "encode UTF-8"
    ],
    "headers"           => {},
  }
end

# dim.jsonの更新
config_path = File.join(@root_dir, 'config', 'dim.json')
config = JSON.parse(File.read(config_path))
config['contents'] = [
  contents_of_akita_city,
  contents_of_daisen_city,
]
File.write(config_path, JSON.pretty_generate(config))
