require 'test_helper'
require 'cell_utils'


class CellUtilsTest < Test::Unit::TestCase
  include CellUtils

  def test_is_number_with_1234
    assert number?('1234')
  end

  def test_is_number_with_1234_d
    assert number?('1234.')
  end

  def test_is_number_with_1234_d_0
    assert number?('1234.0')
  end

  def test_is_number_with_0_d_123
    assert number?('0.123')
  end

  def test_is_number_with_d
    assert_nil number?('.')
  end

  def test_is_number_with_P_1234_d_0
    assert number?('+1234.0')
  end

  def test_is_number_with_N_1234_d_0
    assert number?('-1234.0')
  end

  def test_is_number_with_P__1234_d_0
    assert number?('+ 1234.0')
  end

  def test_is_number_with_N__1234_d_0
    assert number?('- 1234.0')
  end

  def test_is_number_with_W_TRI__1234_d_0
    assert number?('△ 1234.0')
  end

  def test_is_number_with_B_TRI__1234_d_0
    assert number?('▲ 1234.0')
  end


  def test_is_number_with_P_1_234_d_0
    assert number?('+1,234.0')
  end

  def test_number_1234
    assert_equal 1234, number('1234')
  end

  def test_number_1234_d_567
    assert_equal 1234.567, number('1234.567')
  end

  def test_number_1_c_234_d_567
    assert_equal 1234.567, number('1,234.567')
  end

  def test_number_P_1_c_234_d_567
    assert_equal 1234.567, number('+1,234.567')
  end

  def test_number_N__1_c_234_d_567
    assert_equal -1234.567, number('- 1,234.567')
  end

  def test_number_T1__1_c_234_d_567
    assert_equal -1234.567, number('△ 1,234.567')
  end

  def test_number_T2__1_c_234_d_567
    assert_equal -1234.567, number('▲ 1,234.567')
  end

  def test_number_with_2_c_589_c_509
    assert_equal 2588509, number("2,588,509")
  end

  def test_is_location_with_12_d_3456_c_12_d_3456
    assert location?('12.3456,12.3456')
  end

  def test_is_location_with_12_d_3456_c_12_d_3456_c_12_d_3456
    assert_nil location?('12.3456,12.3456,12.3456')
  end


end
  