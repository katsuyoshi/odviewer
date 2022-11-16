require 'json'
require 'singleton'
require 'csv'


class OpenData
  include Singleton


  attr_reader :data

  def initialize
    @root_dir = File.dirname(File.dirname(__FILE__))
    load
  end


  private

  def load
    return @data if @data
    
    @data = {}
    config_path = File.join(@root_dir, 'dim.json')
    config = JSON.parse(File.read(config_path))
    config['contents'].map do |c|
      path = File.join(@root_dir, 'data_files', c['name'], File.basename(c['url']))
      begin
        # @see: https://github.com/ruby/csv/issues/66
        # row内に改行が含まれるとパースできないので前処理で' 'に置換する
        lines = []
        File.read(path).each_line do |l|
          l.chomp!
          if lines.empty? ||
            (lines.last.scan(/\"/).size % 2 == 0 &&
             l.scan(/\"/).size % 2 == 0)
             lines << l 
          else
            lines.last << " #{l}"
          end
        end
        
        @data[c['name']] = CSV.parse(lines.join("\n"), headers:true, liberal_parsing: true) #{double_quote_outside_quote: true})
      rescue
        puts "FAIL: reading #{path}"
      end
    end
  end

end


if $0 == __FILE__
  OpenData.instance.data
end
