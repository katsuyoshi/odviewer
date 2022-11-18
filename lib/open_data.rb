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


class OpenData
  include Singleton


  attr_reader :data, :keys

  def initialize
    @root_dir = File.dirname(File.dirname(__FILE__))
    load
  end

  def updated_at kind
    Time.parse(@config['contents'].find{|c| c['name']}['lastModified']).getlocal
  end

  def keys
    @keys ||= @config['contents'].map{|c| c['name']}
  end


  private

  def load
    return @data if @data
    
    @data = {}
    config_path = File.join(@root_dir, 'dim-lock.json')
    @config = JSON.parse(File.read(config_path))
    @config['contents'].map do |c|
      path = File.join(@root_dir, 'data_files', c['name'], File.basename(c['url']))
      begin
        # @see: https://github.com/ruby/csv/issues/66
        # row内に改行が含まれるとパースできないので前処理でj前の行に追加する
        lines = []
        File.read(path).each_line do |l|
          l.chomp!
          if lines.empty? ||
            (lines.last.scan(/\"/).size % 2 == 0 &&
             l.scan(/\"/).size % 2 == 0)
             lines << l 
          else
            lines.last << "#{l}"
          end
        end
        
        @data[c['name']] = CSV.parse(lines.join("\n"), headers:true, liberal_parsing: true)
        .delete_if{|row| row.map{|e| e.last}.find{|e| e} == nil}
      rescue
        puts "FAIL: reading #{path}"
      end
    end
  end

end


if $0 == __FILE__
  OpenData.instance.data
end
