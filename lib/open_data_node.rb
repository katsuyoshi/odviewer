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

require 'weakref'

class OpenDataNode

  attr_reader :name, :parent, :children

  def initialize name, parent = nil
    @name = name
    @parent = WeakRef.new parent if parent
    @children = {}
    @prev_node = nil
    @next_node = nil
  end

  def [] name
    @children[name]
  end

  def []= name, value
    @children[name] = value
  end

  def entity
    @entity
  end

  def entity= entity
    @entity = entity
    @entity.node = self
  end

  def prev_node
    @prev_node
  end

  def prev_node= node
    @prev_node = WeakRef.new node
    node.next_node ||= self
  end

  def next_node
    @next_node
  end

  def next_node= node
    @next_node = WeakRef.new node
    node.prev_node = self
  end


  def parents
    @parents ||= begin
      a = [self]
      p = @parent
      while p &&  p.name != ""
        a << p
        p = p.parent
      end
      a.reverse
    end
  end

  def classifies
    parents.map{|n| n.name}
  end

  def path
    @path ||= begin
      ([""] + parents.map{|n| n.name}).join("/")
    end
  end

  def leaf?
    !!entity
  end

end
