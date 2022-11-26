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
      .delete_if{|row| row.map{|e| e.is_a?(Array) ? e.last : e}.find{|e| e} == nil}
      csv
    end
  end

  def has_headers?
    @has_headers
  end


end
