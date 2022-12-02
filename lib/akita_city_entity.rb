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
    when  /^８２　秋田港の階級別入港船舶数/,
          /^８３　秋田港の国別輸出入貨物状況/
      return akita_city_entity_pre_process_port lines
    when  /^８４　　秋田空港の利用状況/
      return akita_city_entity_pre_process_port2 lines
    when  /^４４　主 要 文 化 施 設 の 利 用 状 況/,
          /^４４　主要文化施設の利用状況/,
          /^４５　主要スポーツ施設の利用状況/
      return akita_city_entity_pre_process_culture_facilities lines
    when  /^１８９　地 目 別 評 価 面 積 、評 価 額/,
          /^１２９　市 立 秋 田 総 合 病 院 の 利 用 者 数/
      return akita_city_entity_pre_process_area_evaluation lines
    when /^質問１．現在、あなたは「福祉」とどのような関わりがありますか。/
      return akita_city_entity_pre_process_qa lines
    when  "４月５月６月７月８月９月10月11月12月１月２月３月累計",
          "全国県市"
      return akita_city_entity_pre_process_csv lines
    when  /^１５０　身体障害者手帳の交付状況/
      return akita_city_entity_pre_process_physical_disability_note lines
    when  /^１５７　　国　　民　　健　　康　　保　　険/
      return akita_city_entity_pre_process_culture_facilities lines, 2
      #return akita_city_entity_pre_process_physical_disability lines
    when  /^１１７　 二酸化硫黄（SO２）濃度の測定結果/,
          /^１１８　 二酸化窒素\(NO２）濃度の測定結果/,
          /^１１９　一酸化炭素（CO）濃度の測定結果/,
          /^１２０　光化学オキシダント（Ox）濃度の測定結果/,
          /^１２２　浮遊粒子状物質（SPM）の測定結果/,
          /^１３８　乳幼児健康診査の受診状況/,
          /^１３９　結核健康診断の実施状況/
      return akita_city_entity_pre_process_multi_table lines
    when  /^１２１　炭化水素類（HC）濃度の測定結果/
      return akita_city_entity_pre_process_multi_table lines, [3, 4]
    when  /^１３０　夜間休日応急診療所の利用者数/,
          /^１４８　保　育　所　の　概　況/,
          /^４６　文　化　財/,
          /^１３５　各種検診の受診状況/
      return akita_city_entity_pre_process_multi_table lines, 2
    when /^１７０　非　行　少　年　補　導　状　況/
      return akita_city_entity_pre_process_multi_table lines, [4, 3]
    when  /^１７５　秋 田 市 の 歳 入/
      return akita_city_entity_pre_process_revenue lines
    when /^１８５　譲　与　税　と　交　付　金/
      return akita_city_entity_pre_process_multi_table lines, [1, 2, 2]
      #return akita_city_entity_pre_process_gift_tax lines
    when /^１３７　特定健康診査等の受診状況と特定保健指導の実施状況/
      return akita_city_entity_pre_process_multi_table lines, [2, 2, 1]

    when  /^市区町村コード/
      # ヘッダー自動判定, タイトルなし
      return [csv_data_with_lines(lines, nil, false)]
    when   /指定緊急避難場所一覧/
      # ヘッダー自動判定, タイトルあり
      return [csv_data_with_lines(lines, nil, true)]
    when /^開設者名/
      # ヘッダー1, タイトルなし
      return [csv_data_with_lines(lines, 1, false)]
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
          /^１４５　　　生　　　活　　　保　　　護/,
          /^１５４　　厚　生　年　金　保　険/
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
          when /^[\s　]*注）/, /^[\s　]*資料|資料に基づき/, /^[\s　]*※/, /が対象/, lines.last
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
        if /^[\s　]*注）|^[\s　]*資料|^[\s　]*※|が対象/ =~ r[0]
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
        if /^[\s　]*注）|^[\s　]*資料|^[\s　]*※|資料に基づき|が対象/ =~ r[0]
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

  def akita_city_entity_pre_process_port lines
    a = lines_with_rectangle(lines, 0, 1, 2, 100)
    maches = a.select{|e| /^[\(（][\d０１２３４５６７８９]+[\)）]/ =~ e}
    s = 1; e = nil
    maches.map.with_index do |l, i|
      e = (a.index(maches[i + 1]) || a.size)
      lines_with_rectangle(lines, 0, s, -1, e).tap do
        s = e + 1
      end
    end
    .map do |a|
      csv_data_with_lines(a, 2, true)
    end
  end

  def akita_city_entity_pre_process_port2 lines
    a = lines_with_rectangle(lines, 0, 1, 1, 100)
    s = a.index(a.find{|e| /^\s*\(\d+\)/ =~ e})
    e = a.index(a.find{|e| /１月/ =~ e})
    title = a[s]
    s += 1; e += 1

    lines1 = lines[s...e]
    lines2 = lines[s..(s+3)] + lines[e...-1]
    lines1[0] = title + " 年間"
    lines2[0] = title + " 月間"
    [
      csv_data_with_lines(lines1, 3, true),
      csv_data_with_lines(lines2, 3, true)
    ]
  end

  def akita_city_entity_pre_process_culture_facilities lines, headers_size = 4
    a = lines_with_rectangle(lines, 0, 0, 1, 100)
    indexes = a.map.with_index{|l, i| /^年[\s　]*度|^年[\s　]*次/ =~ l ? i : nil}
    indexes.compact!
    size = lines.size
    lines_set = indexes.map.with_index do |index, i|
      s = indexes[i]
      e = indexes[i + 1] || size

      # 秋田県民会館はヘッダーが1行不足しているので補正
      # 市立千秋美術館は空行が入るため1行不足と判断されるので補正
      s -= 1 if /秋田県民会館|市立千秋美術館|太平山自然学習センター/ =~ lines[s]

      a1 = lines[s + 4].split(/\,/)
      w = a1.index(nil) || a1.size
      # 2プロック目からは年度項目を削除してくっつけるため最初の列は不要なので1引いている
      w -= 1 unless i == 0
      
      r = lines_with_rectangle(lines, i == 0 ? 0 : 1, s, w, e - s)
      (1..3).each do |j|
        # 0列が空だとヘッダと認識しないのでダミー追加
        r[j] = " " + r[j]
      end
      r
      
    end

    lines1 = lines_set[1..-1].inject(lines_set.first) do |set, a|
      # ４５　主要スポーツ施設の利用状況（ Ⅱ ） の場合ヘッダーに2行追加する
      # ４５　主要スポーツ施設の利用状況（ Ⅲ  ） の場合ヘッダーに1行追加する
      if /Ⅱ|Ⅲ/ =~ lines[0]
        a.insert(3, "")
      end        
      if /Ⅱ/ =~ lines[0]
        a.insert(3, "")
      end        
      h = 5 
      set.zip(a).map do |a, b|
        [a,b].join(",")
      end
    end


    # マッチする場合はヘッダ行が3行
    h = /公民館（全数分 ）|東部市民サービスセンター/ =~ lines1[0] ? 3 : headers_size
    h = h + 1 if /Ⅵ/ =~ lines[0]
    h = 5 if /Ⅱ/ =~ lines[0]
    [
      csv_data_with_lines(lines1, h, false)
    ]
  end

  def akita_city_entity_pre_process_revenue lines
    akita_city_entity_pre_process_port lines
  end

  def akita_city_entity_pre_process_gift_tax lines
    # TODO:
    []
  end

  def akita_city_entity_pre_process_area_evaluation lines
    akita_city_entity_pre_process_culture_facilities lines, 2
  end

  def akita_city_entity_pre_process_qa lines
    a = lines_with_rectangle(lines, 0, 1, 1, nil)

    indexes = a.map.with_index{|l, i| /^質問[\d１２３４５６７８９０]+$/ =~ l ? i + 1 : nil}.compact
    size = lines.size
    lines_set = indexes.map.with_index do |n,i|
      s = indexes[i]
      e = indexes[i + 1] || size
      lines_with_rectangle(lines, 0, s, nil, e - s)
    end
    
    lines_set.map.with_index do |s, i|
      csv_data_with_lines(s, nil, false)
    end
  end

  def akita_city_entity_pre_process_csv lines

    lines[0] = " " + lines[0]
    [
      csv_data_with_lines(lines, 1, false)
    ]
  end

  # (n) のタイトルが付いた複数のテーブルが配置されているパターン
  def akita_city_entity_pre_process_multi_table lines, header_sizes = 1
    regex = /^\s*[\(（]([\d０１２３４５６７８９]+)[\)）]/
    # "(n)" にマッチする行を探す
    l_a = lines_with_rectangle(lines, 0, 0, 1, 100)
    l_indexes = l_a.map.with_index{|l, i| regex =~ l ? i : nil}.compact
    size = lines.size
    # 列方向でも"(n)"にマッチする列を探す
    # 2番目を探したいので1番目がある0列目は外す
    c_a = lines[l_indexes[0]].split(/\,/)[1..-1]
    # 0列外した分で+1している。=> i + 1
    c_indexes = c_a.map.with_index{|l, i| regex =~ l ? i + 1 : nil}.compact
    c_size = c_indexes.first || 0

    w = c_size <= 1 ? -1 : c_size

    # 左側のテーブル
    l_lines_set = l_indexes.map.with_index do |index, i|
      s = l_indexes[i]
      e = l_indexes[i + 1] || size
      lines_with_rectangle(lines, 0, s, w, e - s)
    end

    # 右側のテーブル
    r_lines_set = []
    unless w == -1
      r_a = lines_with_rectangle(lines, c_size, 0, 1, 100)
      r_indexes = r_a.map.with_index{|l, i| regex =~ l ? i : nil}.compact

      # １８５　譲　与　税　と　交　付　金 の場合したの表までのサイズを測る
      # 令和元年度後の
      if /１８５　/ =~ lines[0]
        f = false
        pt = r_a.map.with_index{|l, i| f = true if /令和元年度/ =~ l; f && l.empty? ? i : nil}.compact.first
        size = pt
      end

      r_lines_set = r_indexes.map.with_index do |index, i|
        s = r_indexes[i]
        e = r_indexes[i + 1] || size
        lines_with_rectangle(lines, c_size, s, nil, e - s)
      end
    end
    
    # 左右合わせて番号順に並べる
    lines_set = (l_lines_set + r_lines_set).sort{|a, b| a[0].scan(regex).first[0] <=> b[0].scan(regex).first[0]}
    lines_set.map.with_index do |s, i|
      hs = header_sizes.is_a?(Array) ? header_sizes[i] || 1 : header_sizes
      csv_data_with_lines(s, hs, true)
    end
  end

  def akita_city_entity_pre_process_physical_disability lines, headers_size = 2
    a = lines_with_rectangle(lines, 3, 1, 1, 100)

    pre_nil = true
    indexes = a.map.with_index do |l, i|
      r = false
      if pre_nil && !l.empty?
        r = true
      end
      pre_nil = l.empty?
      r ? i + 1 : nil
    end.compact

    headers = lines_with_rectangle(lines, 0, indexes[0], nil, headers_size)

    size = lines.size
    lines_set = indexes.map.with_index do |n,i|
      s = indexes[i]
      s += headers_size if i == 0
      e = indexes[i + 1] || size
      lines_with_rectangle(lines, 0, s, nil, e - s)
    end
    
    lines_set.map.with_index do |s, i|
      if i == 0
        csv_data_with_lines(s, nil, false)
      else
        csv_data_with_lines(headers + s, nil, false)
      end
    end
  end

  def akita_city_entity_pre_process_physical_disability_note lines, headers_size = 2
    a = lines_with_rectangle(lines, 1, 1, 1, 100)

    pre_nil = true
    indexes = a.map.with_index do |l, i|
      r = false
      if pre_nil && !l.empty?
        r = true
      end
      pre_nil = l.empty?
      r ? i : nil
    end.compact
    indexes[0] += 1

    headers = lines_with_rectangle(lines, 0, indexes[0], nil, headers_size)

    size = lines.size
    lines_set = indexes.map.with_index do |n,i|
      s = indexes[i]
      s += headers_size if i == 0
      e = indexes[i + 1] || size
      lines_with_rectangle(lines, 0, s, nil, e - s)
    end
    
    lines_set.map.with_index do |s, i|
      if i == 0
        csv_data_with_lines(headers + s, headers_size, false)
      else
        csv_data_with_lines(s.insert(1, headers).flatten, headers_size, true)
      end
    end
  end

    
end