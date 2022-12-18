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
require 'dotenv'

Dotenv.load

Sinatra::Base.register SinatraMore::MarkupPlugin
set :haml, { escape_html: false }

#before '/|/data_table|/viewer' do
#end

before '/*' do
  @od = OpenData.instance
end

get '/viewer/*' do
  @path = params['splat'].first
  @node = @od.node
  @path.split(/\//).each do |e|
    @node = @node[e] unless e.length == 0
  end
  @entity = @node.entity

  haml :viewer, :layout => :layout
end


get '/' do
  @node = @od.node
  haml :index, :layout => :layout
end 


get '/*' do
  @path = params['splat'].first
  @node = @od.node
  @path.split(/\//).each do |e|
    @node = @node[e] unless e.length == 0
  end
  if @node == @od.node
    haml :index, :layout => :layout
  else
    haml :list, :layout => :layout
  end
end 



get '/coffee_test' do
  haml :coffee_test, :layout => :layout
end

get '/js/app.js' do
  coffee :'js/app'
end
