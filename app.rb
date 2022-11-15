require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require 'sass'
require 'coffee-script'
require './scripts/daisen_open_data'
require 'sinatra_more/markup_plugin'
require 'chart_js'

Sinatra::Base.register SinatraMore::MarkupPlugin
set :haml, { escape_html: false }

#before '/|/data_table|/viewer' do
#end

get '/' do
  @daisen_data = DaisenOpenData.instance.data
  haml :index, :layout => :layout
end 

get '/viewer/:kind' do
  @daisen_data = DaisenOpenData.instance.data
  @kind = params[:kind]
  @csv = @daisen_data[@kind]

  case @csv.headers
  when ->(a){ a.include?('年度')}
    csv = @csv
    nendo = csv.map{|r| r['年度']}
    @chart = ChartJS.line do
      data do
        labels nendo || []
        csv.headers.each do |k|
          case k
          when /町村コード/,/都道府県名/,/市町村名/,/年度/
          else
            dataset k do
              color :random
              data csv.map{|r| r[k].gsub(/\,/, "").gsub(/△\s*/, "-").to_f}
            end
          end
        end 
      end
    end
  end
  haml :viewer, :layout => :layout
end

