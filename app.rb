require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require 'sass'
require 'coffee-script'
require './scripts/daisen_open_data'
require 'sinatra_more/markup_plugin'

Sinatra::Base.register SinatraMore::MarkupPlugin
set :haml, { escape_html: false }

before '/|/data_table' do
  @daisen_data = DaisenOpenData.instance.data
end

get '/' do
  haml :index, :layout => :layout
end 

get '/data_table/:kind' do
  @daisen_data = DaisenOpenData.instance.data
#p @daisen_data
  @kind = params[:kind]
  haml :data_table, :layout => :layout
end
