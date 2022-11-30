require 'csv'
require 'cell_utils'

class CsvData
  include  CellUtils

  attr_reader :lines, :has_header, :title
  attr_accessor :graph_type

  def initialize lines, has_headers=true, title=nil
    @lines = lines
    @has_headers = has_headers
    @title = title
    @graph_type = :line
  end

  def csv
    @csv ||= begin
      csv = CSV.parse(lines.join("\n"), headers: has_headers?, liberal_parsing: true)

      # 空の行を削除
      csv.delete_if{|row| row.map{|e| e.is_a?(Array) ? e.last : e}.find{|e| e} == nil}
      
      # 空の列を削除
      if has_headers?
        tbl = {}
        csv.each do |r|
          csv.headers.each do |h|
            tbl[h] ||= []
            tbl[h] << r[h] if r[h]
          end
        end
        empty_keys = tbl.keys.select{|k| tbl[k].empty?}
        empty_keys.each do |k|
          csv.delete(k)
        end
      end

      # スペースの削除とカンマ付き数値の置換
      if has_headers?
        csv.headers.each do |h|
          csv.each do |r|
            r[h] = r[h].strip if r[h].is_a?(String)
            if number?(r[h])
              r[h] = number(r[h])
            else
              r[h]
            end
          end
        end
      else
        csv.each do |r|
          r.each_with_index do |c, i|
            c = c&.strip
            if number?(c)
              r[i] = number(c)
            else
              r[i] = c
            end
          end
        end
      end

      csv
    end
  end

  def has_headers?
    @has_headers
  end


end
