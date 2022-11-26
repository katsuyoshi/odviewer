require 'csv'


class CsvData

  attr_reader :lines, :has_header, :title

  def initialize lines, has_header=true, title=nil
    @lines = lines
    @has_header = has_header
    @title = title
  end

  def csv
    @csv ||= begin
    csv = CSV.parse(lines.join("\n"), headers: has_header?, liberal_parsing: true)
      .delete_if{|row| row.map{|e| e.last}.find{|e| e} == nil}
      csv
    end
  end

  def has_header?
    @has_header
  end


end
