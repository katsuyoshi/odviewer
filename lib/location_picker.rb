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

require 'csv'

class LocationPicker

  attr_reader :locations, :center

  def initialize csv
    @locations = []
    @csv = csv
    gen_locations
  end

  private

  def gen_locations
    return if @csv.is_a? Array
    headers = @csv.headers
    return unless headers.include?('緯度') && headers.include?('経度')
    return unless @csv.find{|r| r['緯度']}

    name_col = headers.find{|e| /名称/ =~ e}
    @locations = @csv.map do |r|
      {
        lat: r['緯度'].to_f,
        long: r['経度'].to_f,
        title: r[name_col],
        url: r['URL']
      }
    end
    if @locations.empty?
      @center = {lat: 39.453179413904934, long: 140.47546896307085}
    else
      lats = @locations.map{|e| e[:lat]}
      longs = @locations.map{|e| e[:long]}
      @center = {lat: (lats.max + lats.min) / 2, long: (longs.max + longs.min) / 2}
    end

  end


end
