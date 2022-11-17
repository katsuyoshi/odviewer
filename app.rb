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
  headers = @csv.headers.map{|e| e&.strip}
  index = @daisen_data.keys.index @kind
  @prev_kind = @daisen_data.keys[index - 1] if index > 0
  @next_kind = @daisen_data.keys[index + 1] if index
  year_col = headers.find{|e| /年[\s　]*度|年[\s　]*次|測[\s　]*定[\s　]*日|^年$/ =~ e}

  if year_col
    nendo = csv.map{|r| r[year_col]}
    @chart = ChartJS.line do
      data do
        labels nendo || []
        headers.each do |k|
          case k
          when /コ[\s　]*ー[\s　]*ド/, /都[\s　]*道[\s　]*府[\s　]*県/, /市[\s　]*町[\s　]*村/, /年[\s　]*度/, /年[\s　]*次/
            next
          end
          values = csv.map{|r| r[k]&.strip}
          next unless number? values.find{|v| v}
          dataset k do
            color :random
            data csv.map{|r| number(r[k]&.strip)}
          end
        end 
      end
    end
  end
  haml :viewer, :layout => :layout
end

