require 'csv'


class CsvData

  attr_reader :lines, :has_header

  def initialize lines, has_header=true
    @lines = lines
    @has_header = has_header
  end

  def csv
p [__LINE__]
    @csv ||= begin
p [__LINE__, lines, has_header?]
    csv = CSV.parse(lines.join("\n"), headers: has_header?, liberal_parsing: true)
      .delete_if{|row| row.map{|e| e.last}.find{|e| e} == nil}
p [__LINE__, csv.class]
      csv
    end
  end

  def has_header?
    @has_header
  end


end
