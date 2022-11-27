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

require 'csv_data'
require 'cell_utils'

module AkitaCityEntity
  include CellUtils

  def akita_city_entity_pre_process lines
    case lines.first
    when /^人　口　世　帯　表/
      return akita_city_entity_pre_process_population lines
    when /^１ 　位　置　と　面　積/, /^２　　市　域　の　変　遷/
      return akita_city_entity_pre_process_without_headers lines
    when /^７　人　口　・　世　帯　の　推　移/
      return akita_city_entity_pre_7_process_population_changes lines
    when /^８　　　人　　　口　　　動　　　態/
      return akita_city_entity_pre_8_process_population_changes lines
    end

    sources = []

    until lines.empty?

      new_lines = []
      ml = lines.find{|l| /^（[０１２３４５６７８９]+）|.+日現在/ =~ l}
      i = lines.index(ml)
      if i
        i += 1
        has_header = true
      else
        if sources.empty?
          i = 0
          has_header = false
        else
          # 2回目以降は区切りが見つかならければ終わりにする。
          lines = []
        end
      end
      lines = lines[i..-1] || []

      found = !has_header
      last = -1
      lines.each_with_index do |l, i|
        unless found
          case l
          when /^\,/
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
          case l
          when /^[\s　]*注）/, /^[\s　]*資料/, lines.last
            last = i + 1
            break
          else
            new_lines << l
          end
        end
      end
      t = CSV.new(ml).first&.first if ml
      sources << CsvData.new(new_lines, has_header, t) unless new_lines.empty?
      new_lines = []
      if last == -1
        lines = []
      else
        lines = lines[last..-1] || []
      end
    end
    sources
  end

  def akita_city_entity_pre_process_population lines
    result = []
    data = {}

    # 世帯数
    t = "人口世帯表"
    data[t] = []
    s = lines.join("\n")
    phase = 0
    csv = CSV.parse(s, liberal_parsing: true).each do |r|
      case phase
      when 0
        case r[1]
        when /世 帯 数/
          phase = 1
          data[t] << r[1,5]
        end
      when 1
        h = data[t].pop
        data[t] << binding_headers(h, r[1,5]).join(",")
        phase = 2
      when 2
        data[t] << to_number(r[1,5]).join(",")
        break
      end
    end

    data['地区別人口世帯表'] = []
    data2 = {}
    phase = 0
    t_l = nil
    t_r = nil
    f_r = false
    headers = nil
    csv = CSV.parse(s, liberal_parsing: true).each do |r|
      case phase
      when 0
        case r[0]
        when /地  区  名/
          phase = 1
          headers = r[0,5]
        end
      when 1
        headers = binding_headers headers, r[0,5]
        headers[1] += "2"
        headers = headers.join(",")
        phase = 2
      when 2
        a1 = to_number(r[0,5])
        if a1[0] && a1[0] != t_l
          t_l = a1[0]
          data[t_l] = [headers]
        end
        unless a1.join("") == ""
          a1[0] = t_l
          a1[1] = t_l if /秋　田　市/ =~ t_l
          data[t_l] << a1.join(",")
        end

        unless f_r
          a2 = to_number(r[6,5])
          if a2.join("") == ""
            f_r = true
            next
          end
          if a2[0] && a2[0] != t_r
            t_r = a2[0]
            data2[t_r] = [headers]
          end
          a2[0] = t_r
          data2[t_r] << a2.join(",")
        end
      end
    end
    data2.each do |k, a|
      data[k] = a
    end

    data['地区別人口世帯表'] << headers
    data.each do |k, a|
      case k
      when '人口世帯表', '地区別人口世帯表'
      else
        if /秋　田　市|計\,/ =~ a[1]
          data['地区別人口世帯表'] << a[1]
        end
      end
    end

    result += data.map{|k, a| CsvData.new(a, true, k)}
  end

  def akita_city_entity_pre_7_process_population_changes lines
    s = lines.join("\n")
    lines1 = []
    lines2 = []

    phase = 0
    headers = nil
    f_l = false
    f_r = false
    csv = CSV.parse(s, liberal_parsing: true).each do |r|
      case phase
      when 0
        case r[0]
        when /^年次/
          phase = 1
          headers = r[0,8]
        end
      when 1
        headers = binding_headers headers, r[0,8]
        lines1 << headers.join(",")
        phase = 2
      when 2
        if /^[\s　]*注）|^[\s　]*資料/ =~ r[0]
          f_l = true
        end
        lines1 << to_number(r[0,8]).join(",") unless f_l
        lines2 << to_number(r[8,8]).join(",") unless f_r
      end
    end
    lines1 += lines2
    [CsvData.new(lines1, true)]
  end

  def akita_city_entity_pre_process_with_headers lines, headers_size = 1
    s = lines.join("\n")
    lines1 = []
    f = false
    hc = 0

    phase = 0
    headers = nil
    csv = CSV.parse(s, liberal_parsing: true).each do |r|
      case phase
      when 0
        # skip first line
        phase = 1
      when 1
        if r[0]
          phase = 2
          headers = r
          hc = 1
        end
      when 2
        headers = binding_headers headers, r
        hc += 1
        if hc >= headers_size
          lines1 << headers.join(",")
          phase = 3
        end
      when 3
        if /^[\s　]*注）|^[\s　]*資料/ =~ r[0]
          f = true
        end
        lines1 << to_number(r).join(",") unless f
      end
    end
    [CsvData.new(lines1, true)]
  end

  def akita_city_entity_pre_process_without_headers lines
    s = lines.join("\n")
    lines1 = []
    f = false

    phase = 0
    csv = CSV.parse(s, liberal_parsing: true).each do |r|
      case phase
      when 0
        # skip first line
        phase = 1
      when 1
        if r[0]
          phase = 2
          lines1 << to_number(r).join(",")
        end
      when 2
        if /^[\s　]*注）|^[\s　]*資料/ =~ r[0]
          f = true
        end
        lines1 << to_number(r).join(",") unless f
      end
    end
    [CsvData.new(lines1, false)]
  end

  def akita_city_entity_pre_8_process_population_changes lines
    [
      csv_data_with_lines(lines_with_rectangle(lines, 0, 0, -1, 26), 3),
      csv_data_with_lines(lines_with_rectangle(lines, 0, 30, 5, 16)),
      csv_data_with_lines(lines_with_rectangle(lines, 6, 30, 5, 16)),
      csv_data_with_lines(lines_with_rectangle(lines, 12, 30, 13, 16)),
    ]
  end



end