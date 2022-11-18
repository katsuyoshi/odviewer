require 'csv'
require 'misc'

class LocationPicker

  attr_reader :locations, :center

  def initialize csv
    @locations = []
    @csv = csv
    gen_locations
  end

  private

  def gen_locations
    headers = @csv.headers
    return unless headers.include?('緯度') && headers.include?('経度')
    return unless @csv.find{|r| r['緯度']}

    name_col = headers.find{|e| /名称/ =~ e}
    @locations = @csv.map do |r|
      {
        lat: r['緯度'].to_f,
        long: r['経度'].to_f,
        title: r[name_col],
        url: r['URL']
      }
    end
    if @locations.empty?
      @center = {lat: 39.453179413904934, long: 140.47546896307085}
    else
      lats = @locations.map{|e| e[:lat]}
      longs = @locations.map{|e| e[:long]}
      @center = {lat: (lats.max + lats.min) / 2, long: (longs.max + longs.min) / 2}
    end

  end


end
