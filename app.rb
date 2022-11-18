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
  od = OpenData.instance
  @daisen_data = od.data
  @kind = params[:kind]
  @updated_at = od.updated_at(@kind)

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
