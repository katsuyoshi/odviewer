require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require 'sass'
require 'coffee-script'
require './scripts/daisen_open_data'
require 'sinatra_more/markup_plugin'

Sinatra::Base.register SinatraMore::MarkupPlugin

before '/|/graph' do
  @daisen_data = DaisenOpenData.instance.data
end

get '/' do
  haml :index, :escape_html => false
end 

get '/graph/:kind' do
  @daisen_data = DaisenOpenData.instance.data
#p @daisen_data
  @kind = params[:kind]
  haml :graph 
end
