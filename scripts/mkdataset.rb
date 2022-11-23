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

# It generates '/dim.json.'

require 'nokogiri'
require 'open-uri'
require 'csv'
require 'json'

@root_dir = File.expand_path("../../", __FILE__)

# データ一覧ファイルからコンテンツを抜き取る
def contents_of prefecture_name, city_name, name_title, url_title
  src_dir = File.join(@root_dir, 'data_files', 'ソースリスト', prefecture_name, city_name)
  path = Dir.chdir(src_dir) do
    p = Dir.glob('*.csv').first
    File.join(src_dir, p) if p
  end
  CSV.foreach(path, headers: true).map do |row|
    {
      'url' => row[url_title],
      'name' => "#{prefecture_name}/#{city_name}/#{row[name_title]}",
      'catalogUrl' => nil,
      'catalogResourceId' => nil,
      'postProcesses' => [ 'encode UTF-8' ],
      'headers' => {},
    }
  end
end

def contents_of_akita_city
  prefecture_name = '秋田県'
  city_name = '秋田市'
  name_title = 'データ名称'
  url_title = 'URL'
  src_dir = File.join(@root_dir, 'data_files', 'ソースリスト', prefecture_name, city_name)
  path = Dir.chdir(src_dir) do
    p = Dir.glob('*.csv').first
    File.join(src_dir, p) if p
  end
  contents = []
  CSV.foreach(path, headers: true).each do |row|
    url = row[url_title]
    title = row[name_title]
    next unless url
    case row['データ形式']
    when 'excel'
      doc = Nokogiri::HTML(URI.open(url))
      doc.search('.opendata').search('.articleall').each do |articl|
        t = articl.search('h3').first.text.strip
        url2 = url[/.*\//] + articl.search('.objectlink').search('.xls').search('a').first['href']
        contents << {
          'url' => url2,
          'name' => "#{prefecture_name}/#{city_name}/#{title}/#{t}",
          'catalogUrl' => nil,
          'catalogResourceId' => nil,
          'postProcesses' => [
            'xlsx-to-csv',
            'encode UTF-8'
          ],
          'headers' => {},
        }
      end
    when 'csv'
      doc = Nokogiri::HTML(URI.open(url))
      doc.search('.opendata').search('.articleall').each do |articl|
        articl.search('.objectlink').search('.csv').each do |c|
          a = c.search('a').first
          url2 = url[/.*\//] + a['href']
          t = a.text.strip
          contents << {
            'url' => url2,
            'name' => "#{prefecture_name}/#{city_name}/#{title}/#{t}",
            'catalogUrl' => nil,
            'catalogResourceId' => nil,
            'postProcesses' => [
              'encode UTF-8' ],
            'headers' => {},
          }
        end
      end
    else
      puts "Unsupported data format \"#{row['データ形式']}\""
    end
  rescue OpenURI::HTTPError => e
    puts "\"#{title}\"'s url \"#{url}\" is missing. #{e}"
  end
  contents
end


# 秋田市と大仙市に対応
contents = 
  contents_of_akita_city +
  #contents_of('秋田県', '大仙市', 'データ名', '公開URL') + 
  []

# dim.jsonの更新
config_path = File.join(@root_dir, 'dim.json')
config = JSON.parse(File.read(config_path))
config['contents'] = contents
File.write(config_path, JSON.pretty_generate(config))
