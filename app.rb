File.expand_path('../lib', __FILE__).tap do |path|
  $LOAD_PATH.unshift path unless $LOAD_PATH.include? path
end

require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require 'sass'
require 'coffee-script'
require 'open_data'
require 'sinatra_more/markup_plugin'
require 'chart_js'
require 'misc'

Sinatra::Base.register SinatraMore::MarkupPlugin
set :haml, { escape_html: false }

#before '/|/data_table|/viewer' do
#end

get '/' do
  @daisen_data = OpenData.instance.data
  haml :index, :layout => :layout
end 

# NG: 乳幼児健診の受診状況
#     住民基本台帳人口・世帯数
get '/viewer/:kind' do
  @daisen_data = OpenData.instance.data
  @kind = params[:kind]
  @csv = @daisen_data[@kind]
  csv = @csv
  headers = @csv.headers
  index = @daisen_data.keys.index @kind
p [@daisen_data.keys, @kind, index, index-1, index+1]
  @prev_kind = @daisen_data.keys[index - 1] if index > 0
  @next_kind = @daisen_data.keys[index + 1] if index
p [@prev_kind, @daisen_data.keys[-1], @next_kind]
  case headers
  when ->(a){ %w(年度 年次).find{|k| a.include?(k)}}
    nendo = csv.map{|r| r['年度'] || r['年次']}
    @chart = ChartJS.line do
      data do
        labels nendo || []
        headers.each do |k|
          case k
          when /コード/, /都道府県/, /市町村/, /年次/
            next
          end
          values = csv.map{|r| r[k]&.strip}
          next unless number? values.find{|v| v}
          dataset k do
            color :random
            data csv.map{|r| number(r[k])}
          end
        end 
      end
    end
  end
  haml :viewer, :layout => :layout
end

