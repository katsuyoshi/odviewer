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

require 'csv'
require 'chart_js'
require 'misc'

class ChartMaker

  attr_reader :charts, :titles

  # 年次項目判定用
  YearRegex = /年[\s　]*度|年[\s　]*次|測[\s　]*定[\s　]*日|^年$/

  # 数値として扱わない項目判定用
  NonNumberRegex = /コ[\s　]*ー[\s　]*ド|都[\s　]*道[\s　]*府[\s　]*県|市[\s　]*町[\s　]*村|年[\s　]*度|年[\s　]*次/

  # グループに分類する項目判定用
  PriorityGroups = %w(産業分類 面積規模 地区 階級 種別 河川名 路線名 図書館名 障がい部位 分類 産業大分類 内訳 施設名 公民館名 事業名 区分 区域)
  GroupRegex = /(?=地域.*)(?!.*コード)/

  # 数値として扱わない項目判定用
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

    # グループ化を試して
    gen_grouped_line_chart
    # 該当しなければグループ化なしのグラフにする
    gen_line_chart if @charts.empty?
  end

  def gen_line_chart
    csv = @csv
    headers = @csv.headers.map{|e| e&.strip}
    year_col = headers.find{|e| YearRegex =~ e}
  
    if year_col
      nendo = csv.map{|r| r[year_col]}
      chart = ChartJS.line do
        data do
          labels nendo || []
          headers.each do |k|
            case k
            when NonNumberRegex
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

    year_col = headers.find{|e| YearRegex =~ e}
    return unless year_col

    group_col = headers.find{|e| PriorityGroups.find{|g| /#{g}/ =~ e}}
    #group_col = PriorityGroups.find{|g| headers.find{|e| /#{g}/ =~ e}}
    group_col ||= headers.find{|e| GroupRegex =~ e}

    # グループ化する項目の内容が1種類しかない場合グループ化しない
    group_col = nil if csv.group_by{|r| r[group_col]}.size <= 1

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
                when NonNumberRegex
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
          when NonNumberRegex
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
                  data r.map{|r| number(r[k]&.strip)}
                end
              end
            end
          end
          @charts << chart
          @titles << k
    
        end
      end

    else
      gen_line_chart
    end
  end

end
