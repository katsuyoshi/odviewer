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
require 'chart_maker'
require 'location_picker'


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

  index = @daisen_data.keys.index @kind
  @prev_kind = @daisen_data.keys[index - 1] if index > 0
  @next_kind = @daisen_data.keys[index + 1] if index

  @csv = @daisen_data[@kind]
  csv = @csv
  gen = ChartMaker.new csv, @kind
  @charts = gen.charts
  @titles = gen.titles
  loc_gen = LocationPicker.new csv
  @locations = loc_gen.locations
  @center = loc_gen.center

  haml :viewer, :layout => :layout
end

get '/coffee_test' do
  haml :coffee_test, :layout => :layout
end

get '/js/app.js' do
  coffee :'js/app'
end
