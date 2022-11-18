require 'csv'
require 'chart_js'
require 'misc'

class ChartGenerator

  attr_reader :charts, :titles

  def initialize csv, kind, group_dir = :opposit
    @csv = csv
    @kind = kind
    @group_dir = group_dir
    gen_chart
  end

  private

  def gen_chart
    @charts = []
    @titles = []
    if @csv.headers.include?("地域")
      gen_grouped_line_chart
    else
      gen_line_chart
    end
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
      @titles << ""
    end
  end

  def gen_grouped_line_chart
    csv = @csv
    headers = @csv.headers.map{|e| e&.strip}

    year_col = headers.find{|e| /年[\s　]*度|年[\s　]*次|測[\s　]*定[\s　]*日|^年$/ =~ e}
    return unless year_col

    group_col = headers.find{|e| /地域/ =~ e}
    if group_col
      case @group_dir
      when :normal
        csv.group_by{|r| r[group_col]}.each do |k,rows|
          nendo = rows.map{|r| r[year_col]}
          chart = ChartJS.line do
            data do
              labels nendo || []
              headers.each do |k|
                case k
                when /コ[\s　]*ー[\s　]*ド/, /都[\s　]*道[\s　]*府[\s　]*県/, /市[\s　]*町[\s　]*村/, /年[\s　]*度/, /年[\s　]*次/
                  next
                end
                values = rows.map{|r| r[k]&.strip}
                next unless number? values.find{|v| v}
                dataset k do
                  color :random
                  data rows.map{|r| number(r[k]&.strip)}
                end
              end 
            end
          end
          @charts << chart
          @titles << k   
        end

      when :opposit

        group = csv.group_by{|r| r[group_col]}
        csv.headers.each do |k|
          case k
          when /コ[\s　]*ー[\s　]*ド/, /都[\s　]*道[\s　]*府[\s　]*県/, /市[\s　]*町[\s　]*村/, /年[\s　]*度/, /年[\s　]*次/
            next
          end
          values = csv.map{|r| r[k]&.strip}
          next unless number? values.find{|v| v}

          
          chart = ChartJS.line do
            data do
              nendo = group.first.last.map{|r| r[year_col]}
              labels nendo
              group.each do |g, r|
                dataset g do
                  color :random
                  data r.map{|r| r[k]&.strip}
                end
              end
            end
          end
          @charts << chart
          @titles << k
    
        end
      end

    end
  end

end
