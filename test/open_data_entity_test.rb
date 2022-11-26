require 'test_helper'

class OpenDataEntiityTest < Test::Unit::TestCase

  setup do
    @od = OpenData.instance
    @entiity = @od['秋田県']['秋田市']['住民基本台帳人口']['人口・世帯の推移'].entity
  end

  def test_csv
    assert_not_nil @entiity.csv
  end

  def test_csv_headers
    assert_equal [], @entiity.csv.headers
  end

end
