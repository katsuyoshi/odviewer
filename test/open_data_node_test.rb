require 'test_helper'

class OpenDataNodeTest < Test::Unit::TestCase

  setup do
    @od = OpenData.instance
  end

  def test_akita_pref
    assert_equal '秋田県', @od['秋田県'].name
  end

  def test_akita_city
    assert_equal '秋田市', @od['秋田県']['秋田市'].name
  end

  def test_pupulation_akita_city
    assert_equal '住民基本台帳人口', @od['秋田県']['秋田市']['住民基本台帳人口'].name
    assert_equal ['秋田県', '秋田市', '住民基本台帳人口'], @od['秋田県']['秋田市']['住民基本台帳人口'].classifies
    assert_equal '/秋田県/秋田市/住民基本台帳人口', @od['秋田県']['秋田市']['住民基本台帳人口'].path
  end

end
