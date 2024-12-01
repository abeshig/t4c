require 'minitest/autorun'
require_relative 'pdf.rb'

class TestPDFHelper < Minitest::Test
  using PDF::Helper

  def test_Integer_div_op
    assert_equal Rational(1,3), 1/3
    assert_equal 0.5, 1.0/2
  end

  def test_Numeric_mm
    assert_equal Rational(720, 254), 1.mm
    assert_equal 720, 254.mm
    assert_equal 72, (25.4).mm
    assert_equal Rational(240, 254), (1/3).mm
  end

end