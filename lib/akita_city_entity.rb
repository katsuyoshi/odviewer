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

module AkitaCityEntity

  def akita_city_entity_pre_process lines
    ml = lines.find{|l| /日現在/ =~ l}
    i = lines.index(ml)
    if i
      i += 1
      @has_header = true
    else
      @has_header = false
      return lines
    end

    lines = lines[i..-1]

    new_lines = []
    found = false
    lines.each do |l|
      unless found
        if /^\,/ =~ l
          ll = new_lines.pop
          t = ""
          elements = CSV.new(ll).to_a.first.zip(CSV.new(l).to_a.first)
          .map do |a|
            t = a.first if a.first && a.first.length != 0
            [t, a.last || ""].join(" ").strip
          end if ll
          new_lines << elements.join(",")
        else
          new_lines << l
          found = new_lines.size > 1
        end
      else
        new_lines << l
      end
    end
    new_lines
  end

end