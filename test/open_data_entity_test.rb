require 'test_helper'

class OpenDataEntiityTest < Test::Unit::TestCase

  setup do
    @od = OpenData.instance
    @entiity = @od['秋田県']['秋田市']['人口・世帯の推移'].entity
  end

  def test_csv
    assert_not_nil @entiity.csv
  end

  def test_csv_headers
    expected = ["年次",
    "人口 総数",
    "人口 男",
    "人口 女",
    "対前年人口 増減数",
    "対前年人口 増減率",
    "世帯数",
    "１世帯当たり の人員",
    "年次",
    "人口 総数",
    "人口 男",
    "人口 女",
    "対前年人口 増減数",
    "対前年人口 増減率",
    "世帯数",
    "１世帯当たり の人員"]
    assert_equal expected, @entiity.csv.headers
  end

end
