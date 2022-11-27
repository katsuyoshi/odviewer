require 'csv'


class CsvData

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
      
      csv.delete_if{|row| row.map{|e| e.is_a?(Array) ? e.last : e}.find{|e| e} == nil}
      
      # 値が空の項目を削除
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

      csv
    end
  end

  def has_headers?
    @has_headers
  end


end
