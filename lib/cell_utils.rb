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


module CellUtils

  def number? v
    return nil if v.nil?
    return true if v.is_a? Numeric
    return nil if location? v
    /^[△▲+-]?\s*(\d{1,3}?(\,\d{3})*|\d+)(\.|\.(\d+))?$/ =~ v
  end
  
  def number v
    return nil unless number? v
    return v if v.is_a? Numeric
    if /\./ =~ v
      v.gsub(/[△▲]/, "-").gsub(/[\s\,]/, '').to_f
    else
      v.gsub(/[△▲]/, "-").gsub(/[\s\,]/, '').to_i
    end
  end

  def location? v
    return nil unless v.scan(/\./).size == 2
    return nil unless v.scan(/\,/).size == 1
    v.split(",").each do |e|
      return nil unless number? e.strip
    end
    true
  end

  def binding_headers headers1, headers2
    pa = pb = nil
    headers1.zip(headers2).map do |a,b|
      "#{a || pa} #{b || pb}".strip.tap do
        pa = a if a
        pb = b if b
      end
    end
  end

  def uniq_headers headers
    # nilを前の項目と同じにする
    headers = binding_headers headers, [nil] * headers.size

    # 重複確認
    a = []
    # セル接合している場合後にタイトルと関連している内容があるので逆から探す
    headers.reverse.map.with_index do |h, i|
      t = h; no = 2
      # 重複していたら数値を後につけてユニーク化する
      while a.find{|e| e == t}
        t = "#{h}#{no}"
        no += 1
      end
      a << t
    end
    a.reverse
  end


  def to_number a
    a.map do |e|
      e&.strip!
      if number? e
        number e
      else
        e
      end
    end
  end


  def csv_data_with_lines lines, headers_size=nil, with_title=true
    s = lines.join("\n")
    lines1 = []
    f = false
    title = nil
    headers_count = 0
    headers_row = []
    headers = []

    phase = with_title ? 0 : 1
    csv = CSV.parse(s, liberal_parsing: true).each do |r|
      case phase
      when 0
        # get title
        title = r[0]
        phase = 1
      when 1
        unless r.join("") == ""
          if r[0]
            headers_row << r
            headers_count = 1
            if headers_size && headers_size <= headers_count
              headers = uniq_headers(headers_row.first)
              lines1 << headers.join(",")
              headers_row = []
              phase = 3
            else
              phase = 2
            end
          end
        end
      when 2
        headers_row << r
        headers_count += 1
        if headers_size && headers_size <= headers_count
          headers = uniq_headers(
            headers_row[1..-1].inject(headers_row[0]) do |h, r|
              binding_headers h, r
            end
          )
          lines1 << headers.join(",")
          phase = 3
        else
          if /^(明治|大正|昭和|平成|令和|\d+)|総[\s　]*数/ =~ r[0]
            headers = uniq_headers(
              headers_row[1..-2].inject(headers_row[0]) do |h, r|
                binding_headers h, r
              end
            )
            lines1 << headers.join(",")
            lines1 << headers_row.last.join(",")
            headers_count -= 1
            headers_row = []
            phase = 3
          end
        end
      when 3
        if /^[\s　]*注）|^[\s　]*資料|資料に基づき/ =~ r[0]
          f = true
        end
        lines1 << to_number(r).join(",") unless f
      end
    end
    if lines1.empty?
      lines1 = headers_row
      headers_row = []
      headers_count = 0
    end
    CsvData.new(lines1, headers_count != 0, title)
  end

  def lines_with_rectangle lines, x, y, w, h
    results = []
    CSV.parse(lines.join("\n"), liberal_parsing: true).each_with_index do |r, i|
      if (y...(y+h)).include? i
        if w == -1
          results << to_number(r).join(",")
        else
          results << to_number(r[x, w]).join(",")
        end
      end
    end
    results
  end

end

