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
p lines.first, lines.first.split(/\,/).join("")
    case lines.first.split(/\,/).join("")
    when /^人　口　世　帯　表/
      return akita_city_entity_pre_process_population lines
    when /^１ 　位　置　と　面　積/
      return akita_city_entity_pre_process_without_headers lines

    when /^３　都　市　計　画　用　途　地　域　別　面　積/
      # (n) タイトルで分離されているパターン
      titles = lines.select{|e| /^（[０１２３４５６７８９]+）/ =~ e}
      indexes = titles.map{|t| lines.index t}
      return indexes.map.with_index do |n, i|
        unless n == indexes.last
          csv_data_with_lines(lines[n...(indexes[i + 1])], 2, true)
        else
          csv_data_with_lines(lines[n..-1], 2, true)
        end
      end
    when /^６　　　気　　　　　象/
      return akita_city_entity_pre_process_weather lines
    when /^７　人　口　・　世　帯　の　推　移/
      return akita_city_entity_pre_process_population_changes_7 lines
    when /^８　　　人　　　口　　　動　　　態/
      return akita_city_entity_pre_process_population_changes_8 lines
    when /^１２　外　国　人　人　口/
      return akita_city_entity_pre_process_population_of_foreigners lines
    when /^１４０　職　業　紹　介　＜ Ⅲ ＞/
      return akita_city_entity_pre_process_job lines
    else
      # ヘッダー自動判定, タイトルなし
      return [csv_data_with_lines(lines[1..-1], nil, false)]
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
          when /^[\s　]*注）/, /^[\s　]*資料|資料に基づき/, lines.last
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
    title = lines_with_rectangle(lines, 1, 3, 1, 1).first
    headers = lines_with_rectangle(lines, 1, 3, 5, 2)
    lines1 = 
      [title + " (1月)"] +
      headers + 
      lines_with_rectangle(lines, 1, 5, 5, 1)

      title = lines_with_rectangle(lines, 7, 2, 1, 1).first
    headers = lines_with_rectangle(lines, 7, 3, 5, 2)
    headers = headers.map{|h| " " + h}
    lines2 = 
      [title] +
      headers + 
      lines_with_rectangle(lines, 7, 5, 5, 2)
  
      title = lines_with_rectangle(lines, 0, 7, 1, 1).first
    headers = lines_with_rectangle(lines, 0, 8, 6, 2)
    lines3 = 
      [title] +
      headers + 
      lines_with_rectangle(lines, 0, 10, 6, 57) +
      lines_with_rectangle(lines, 6, 10, 6, 19)
    lines3 = lines3.map.with_index do |l, i|
      if i >= 3
        csv = CSV.new l
        a = csv.to_a.first
        a[0] = a[1] = a[0] || a[1]
        l = a.join(",")
      end
      l
    end

    [
      csv_data_with_lines(lines1, 2),
      csv_data_with_lines(lines2, 2),
      csv_data_with_lines(lines3, 2),
    ]
  end

  def akita_city_entity_pre_process_population_changes_7 lines
    headers = lines_with_rectangle(lines, 0, 1, 8, 2)
    lines1 = headers + 
              lines_with_rectangle(lines, 0, 3, 8, 41) + 
              lines_with_rectangle(lines, 8, 4, 8, 40)
    [
      csv_data_with_lines(lines1, 2, false),
    ]
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
        if /^[\s　]*注）|^[\s　]*資料|資料に基づき/ =~ r[0]
          f = true
        end
        lines1 << to_number(r).join(",") unless f
      end
    end
    [CsvData.new(lines1, false)]
  end

  def akita_city_entity_pre_process_population_changes_8 lines
    title = lines_with_rectangle(lines, 0, 1, 1, 1).first
    headers = lines_with_rectangle(lines, 0, 2, -1, 3)
    [
      csv_data_with_lines(
        [title + " 年別"] +
          headers +
          lines_with_rectangle(lines, 0, 5, -1, 10),
        3
      ),
      csv_data_with_lines(
        [title + " 月別"] +
          headers +
          lines_with_rectangle(lines, 0, 15, -1, 12),
        3
      ),
      csv_data_with_lines(lines_with_rectangle(lines, 0, 30, 5, 17)),
      csv_data_with_lines(lines_with_rectangle(lines, 6, 30, 5, 17)),
      csv_data_with_lines(lines_with_rectangle(lines, 12, 30, 13, 17)),
    ]
  end

  def akita_city_entity_pre_process_weather lines
    lines1 = lines_with_rectangle(lines, 0, 1, 9, 14)
    lines1[0].gsub!(/気象/, "気象 年別")
    # ヘッダーがnilで始まるので" "を追加して認識される様に
    lines1[1] = " " + lines1[1]

    lines2 = lines1[0,4].map{|e| e.dup} + lines_with_rectangle(lines, 0, 16, 9, 12)
    lines2[0].gsub!(/気象 年別/, "気象 月別")

    title = lines_with_rectangle(lines, 10, 1, 1, 1).first
    headers = lines_with_rectangle(lines, 10, 2, 9, 1)

    lines_set = 4.times.map do |i|
      offset = i * 13 - (i >= 3 ? 1 : 0)
      [title + " " + lines_with_rectangle(lines, 11, 6 + offset, 1, 1).first] +
        headers + 
        lines_with_rectangle(lines, 10, 8 + offset, 9, 10)
    end
          
    [
      csv_data_with_lines(lines1, 3, true),
      csv_data_with_lines(lines2, 3, true),
    ] + 
    lines_set.map do |set|
      csv_data_with_lines(set, 1, true)
    end
  end

  def akita_city_entity_pre_process_population_of_foreigners lines
    [
      csv_data_with_lines(
        lines_with_rectangle(lines, 0, 2, -1, 11).zip( 
        lines_with_rectangle(lines, 0, 13, -1, 11))
          .map{|a,b| a + b.split(/\,/)[1..-1].join(",")},
        1, false),
    ]
  end

  def akita_city_entity_pre_process_job lines
    title = lines_with_rectangle(lines, 0, 1, 1, 1).first
    headers = lines_with_rectangle(lines, 0, 2, -1, 1)
    [
      csv_data_with_lines(
        [title + " 年別"] +
          headers +
          lines_with_rectangle(lines, 0, 3, -1, 10),
        1
      ),
      csv_data_with_lines(
        [title + " 月別"] +
          headers +
          lines_with_rectangle(lines, 0, 13, -1, 12),
        1
      ),
    ]
  end


end