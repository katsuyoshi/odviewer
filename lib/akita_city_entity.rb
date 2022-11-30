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
    when /^人[\s　]*口[\s　]*世[\s　]*帯[\s　]*表/
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
    when  /^１８７　　　市　　　有　　　財　　　産/
      return akita_city_entity_pre_process_properties lines
    when  /^市区町村コード/
      # ヘッダー自動判定, タイトルなし
      return [csv_data_with_lines(lines, nil, false)]
    when  /^４４　主 要 文 化 施 設 の 利 用 状 況/,
          /指定緊急避難場所一覧/
      # ヘッダー自動判定, タイトルあり
      return [csv_data_with_lines(lines, nil, true)]
    when /^開設者名/
      # ヘッダー1, タイトルなし
      return [csv_data_with_lines(lines, 1, false)]
    when  /^質問１/,
          /^１１９　一酸化炭素（CO）濃度の測定結果/,
          /^１２０　光化学オキシダント（Ox）濃度の測定結果/,
          /^１２１　炭化水素類（HC）濃度の測定結果/,
          /^１２０　光化学オキシダント（Ox）濃度の測定結果/,
          ",４月,５月,６月,７月,８月,９月,10月,11月,12月,１月,２月,３月,累計",
          ",全国,県,市"
      # TODO: 複数テーブル
      return [csv_data_with_lines(lines, nil, false)]
    when /^１３１　死　因　順　位　別　死　亡　者　数/
      return [csv_data_with_lines(lines[1..-1], 2, false)]
    when  /^１４１　　雇　　用　　保　　険　/, 
          /^１４３　労　働　者　災　害　補　償　保　険/, 
          /^１４４　労 働 組 合 と 組 合 員 の 状 況/, 
          /^１４４　労　働　組　合　と　組　合　員　の　状　況/, 
          /^５９　漁　業　の　概　況/, 
          /^４７　事　業　所　数/, 
          /^７９　主要金融機関の預金・貸出金状況/, 
          /^１１３　電　灯 ・ 電　力　需　要　状　況/,
          /^８２　秋田港の階級別入港船舶数/,
          /^８３　秋田港の国別輸出入貨物状況/,
          /^８４　　秋田空港の利用状況/,
          /^４６　文　化　財/,
          /^１７５　秋 田 市 の 歳 入/,
          /^１７０　非　行　少　年　補　導　状　況/,
          /^１１７　 二酸化硫黄（SO２）濃度の測定結果/,
          /^１１８　 二酸化窒素\(NO２）濃度の測定結果/,
          /^１４５　　　生　　　活　　　保　　　護/,
          /^１４８　保　育　所　の　概　況/,
          /^１５４　　厚　生　年　金　保　険/,
          /^１３０　夜間休日応急診療所の利用者数/,
          /^１３５　各種検診の受診状況/,
          /^１３７　特定健康診査等の受診状況と特定保健指導の実施状況/,
          /^１３８　乳幼児健康診査の受診状況/,
          /^１３９　結核健康診断の実施状況/
      # ヘッダー自動判定, タイトルあり
      return [csv_data_with_lines(lines[1..-1], nil, true)]
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
            new_lines << join_rows(elements)
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

    # 左側の表サイズ探索
    # 秋田市の下に空行があるので、2回目(t=true)のnilの位置を検索
    t = nil
    a = lines_with_rectangle(lines, 0, 10, 2, 100)
    row1_size = a.map{|e| e&.strip}.index do |e|
      r = t && e == ","
      tt ||= e == (",")
      print e == (",") ? "M" : ""
      print t ? "T" : "."
      r
    end || a.size

    # 右側の表サイズ探索
    a = lines_with_rectangle(lines, 6, 10, 2, 100)
    row2_size = a.map{|e| e&.strip}.index(",") || a.size

    lines3 = 
      [title] +
      headers + 
      lines_with_rectangle(lines, 0, 10, 6, row1_size) +
      lines_with_rectangle(lines, 6, 10, 6, row2_size)

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
          lines1 << join_rows(headers)
          phase = 3
        end
      when 3
        if /^[\s　]*注）|^[\s　]*資料/ =~ r[0]
          f = true
        end
        lines1 << join_rows(to_number(r)) unless f
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
          lines1 << join_rows(to_number(r))
        end
      when 2
        if /^[\s　]*注）|^[\s　]*資料|資料に基づき/ =~ r[0]
          f = true
        end
        lines1 << join_rows(to_number(r)) unless f
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
          .map{|a,b| a + join_rows(b.split(/\,/)[1..-1])},
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

  def akita_city_entity_pre_process_properties lines
    a = lines_with_rectangle(lines, 0, 1, 2, 100)
    maches = a.select{|e| /^\(\d+\)/ =~ e}
    s = 1; e = nil
    lines_set = maches.map.with_index do |l, i|
      e = a.index(maches[i + 1]) || a.size
      lines_with_rectangle(lines, 0, s, -1, e).tap do
        s = e + 1
      end
    end

    index = a.index(a.find{|l| /^建物（延面積）/ =~ l})
    lines1 = lines_set[0][0...index].dup
    lines1[0] = lines1[0].gsub("行政財産", "行政財産 土地（地積）").dup
    lines2 = (lines_set[0][0,3] + lines_set[0][index..-1]).dup
    lines2[0] = lines1[0].gsub("行政財産 土地（地積）", "行政財産 建物（延面積）").dup
    [
      csv_data_with_lines(lines1, 2, true),
      csv_data_with_lines(lines2, 2, true),
      csv_data_with_lines(lines_set[1], 2, true)
    ]
  end

=begin
  def akita_city_entity_pre_process_properties lines
    p [__LINE__]
        a = lines_with_rectangle(lines, 0, 1, 2, 100)
    p [__LINE__]
        maches = a.select{|e| /^\(\d+\)/ =~ e}
    p [__LINE__, maches]
        s = 1; e = nil
    p [__LINE__, s, e]
        maches.map.with_index do |l, i|
    p [__LINE__, l, maches[i + 1]]
          e = (a.index(maches[i + 1]) || a.size) + 1
    p [__LINE__, e]
          lines_with_rectangle(lines, 0, s, -1, e).tap do
    p [__LINE__, s, e]
            s = e
          end
        end
        .map do |a|
          csv_data_with_lines(a, 2, true)
        end
      end
=end
    
end