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
require 'cell_utils'

require 'akita_city_entity'

class OpenDataEntity
  include AkitaCityEntity

  attr_reader :url, :path, :classifies, :name, :file_name, :csvs, :title
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

  private

  def load_csv_data lines
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
      @title = lines[0]&.split(/\,/).join("")

      # 一度CSVに変換し空行削除と数値のカンマを取り除く
      csv_data = CsvData.new lines, false, nil
      lines = csv_data.csv.map do |r|
        CellUtils.join_rows(r.to_a)
      end

      load_csv_data lines
    rescue => e
      puts "FAIL: reading #{path}"
      p e
      puts e.backtrace
      []
    end
  end


end
