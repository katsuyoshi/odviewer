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

require 'json'
require 'singleton'
require 'csv'
require 'time'

require 'akita_city_entity'

class OpenDataEntity
  include AkitaCityEntity

  attr_reader :url, :path, :classifies, :name, :file_name, :csvs
  attr_reader :updated_at, :checked_at

  def initialize config
    @url = config['url']
    @path = config['path'].gsub(/^\.\//, "").gsub(/\.xls(x)?$/, ".csv")
    @classifies = @path.split(/\//)

    # "path": "./data_files/国保加入被保険者の状況/02_.csv",
    # remove first & last elements
    @file_name = @classifies.last
    @classifies.pop
    @classifies.shift
    
    @name = @classifies.last

    @updated_at = Time.parse config['lastModified']
    @checked_at = Time.parse config['lastDownloaded']

    @root_dir = File.expand_path("../../", __FILE__)
  end

  def node
    @node
  end

  def node= node
    @node = WeakRef.new node if node
  end

  def csv
    csvs.first
  end

  def csv_data
    @csv_data ||= begin
      load
    end
  end

  def csvs
    csv_data.map{|d| d.csv}
  end

  def has_header?
    @has_header
  end

  private

  def load_pre_process lines
    case node.parents[1].name
    when "秋田市"
      akita_city_entity_pre_process lines
    else
      CsvData.new lines
    end
  end

  def load    
    @csv_data ||= begin
      path = File.join(@root_dir, self.path)
      # @see: https://github.com/ruby/csv/issues/66
      # row内に改行が含まれるとパースできないので前処理で前の行に追加する
      lines = []
      File.read(path).each_line do |l|
        l.chomp!
        if lines.empty? ||
          lines.last.scan(/\"/).size % 2 == 0
            lines << l 
        else
          lines.last << "#{l}"
        end
      end
      # 空行の削除
      lines = lines.select{|l| l.split(/\,/).join("") != ""}

      # [String, String, String ..., String] =>
      # [CsvData, CsvData, ...]
      load_pre_process lines
    rescue => e
      puts "FAIL: reading #{path}"
      p e
      puts caller
      []
    end
  end


end

__END__

{
  "name": "秋田県/秋田市/位置と面積/位置と面積",
  "url": "https://www.city.akita.lg.jp/shisei/tokei/1003666/../../../_res/projects/default_project/_page_/001/003/561/03-1.xls",
  "path": "./data_files/秋田県/秋田市/位置と面積/位置と面積/03-1.xls",
  "catalogUrl": null,
  "catalogResourceId": null,
  "lastModified": "2022-04-20T23:35:48.000Z",
  "eTag": "7600-5dd1e740736c0",
  "lastDownloaded": "2022-11-23T14:37:04.030Z",
  "integrity": "",
  "postProcesses": [
    "xlsx-to-csv",
    "encode UTF-8"
  ],
  "headers": {}
},

