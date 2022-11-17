require 'csv'
require 'chart_js'
require 'misc'

class ChartGenerator

  attr_reader :charts, :titles

  def initialize csv, kind
    @csv = csv
    @kind = kind
    gen_chart
  end

  private

  def gen_chart
    @charts = []
    gen_line_chart
  end

  def gen_line_chart
    csv = @csv
    headers = @csv.headers.map{|e| e&.strip}
    year_col = headers.find{|e| /年[\s　]*度|年[\s　]*次|測[\s　]*定[\s　]*日|^年$/ =~ e}
  
    if year_col
      nendo = csv.map{|r| r[year_col]}
      chart = ChartJS.line do
        data do
          labels nendo || []
          headers.each do |k|
            case k
            when /コ[\s　]*ー[\s　]*ド/, /都[\s　]*道[\s　]*府[\s　]*県/, /市[\s　]*町[\s　]*村/, /年[\s　]*度/, /年[\s　]*次/
              next
            end
            values = csv.map{|r| r[k]&.strip}
            next unless number? values.find{|v| v}
            dataset k do
              color :random
              data csv.map{|r| number(r[k]&.strip)}
            end
          end 
        end
      end
      @charts << chart
    end
  end

end
