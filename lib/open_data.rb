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
require 'open_data_entity'
require 'open_data_node'

class OpenData
  include Singleton

  attr_reader :entities, :node

  def initialize
    @entities = nil
    @root_dir = File.dirname(File.dirname(__FILE__))
    load
  end

  def [] name
    @node.children[name]
  end


  private

  def load
    return if @entities
    
    @entities = {}
    @node = OpenDataNode.new("")

    config_path = File.join(@root_dir, 'dim-lock.json')
    @config = JSON.parse(File.read(config_path))
    @config['contents'].map do |c|
      entity = OpenDataEntity.new(c)
      @entities[entity.path] = entity

      n = @node
      entity.classifies.each do |e|
        n[e] ||= OpenDataNode.new(e, n)
        n = n[e]
      end
      n.entity = entity
    end

    prev_node = @entities[@entities.keys.last].node
    @entities.each do |n, e|
      node = e.node
      node.prev_node = prev_node
      prev_node = node
    end

  end

  def dump_node
    node.children.map do |n|
      n.children.map{|e| e.name}
    end
  end

end
