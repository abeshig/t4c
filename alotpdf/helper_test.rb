require 'minitest/autorun'
require_relative 'pdf.rb'

class TestHelperConstruct < Minitest::Test
  include AlotPDF::Helper::Construct

  def test_Point
    a = lambda {|*arg, **kw| AlotPDF::Point.new(*arg, **kw) }
    t = lambda {|*arg, **kw| Point(*arg, **kw) }
    assert_equal a.(50, 100), t.(AlotPDF::Point.new(50, 100))
    assert_equal a.(100, 200), t.(100, 200)
    assert_equal a.(150, 300), t.(y: 300, x: 150)
    assert_equal a.(200, 400), t.(x: 200, y: 400, xy: 150)
    assert_raises(StandardError) { t.() }
    assert_raises(StandardError) { t.(10) }
    assert_raises(StandardError) { t.(10, 20, 30) }
    assert_raises(StandardError) { t.(x: 10) }
    assert_raises(StandardError) { t.(y: 30) }
  end

  def test_Size
    a = lambda {|*arg, **kw| AlotPDF::Size.new(*arg, **kw) }
    t = lambda {|*arg, **kw| Size(*arg, **kw) }
    assert_equal a.(50, 100), t.(AlotPDF::Size.new(50, 100))
    assert_equal a.(100, 200), t.(100, 200)
    assert_equal a.(150, 300), t.(height: 300, width: 150)
    assert_equal a.(100, 300), t.(width: 100, height: 300, size: 150)
    assert_raises(StandardError) { t.() }
    assert_raises(StandardError) { t.(10) }
    assert_raises(StandardError) { t.(50, 100, 200) }
    assert_raises(StandardError) { t.(width: 100) }
    assert_raises(StandardError) { t.(height: 200) }
  end

  def test_LineWidth
    a = lambda {|*arg, **kw| AlotPDF::LineWidth.new(*arg, **kw) }
    t = lambda {|*arg, **kw| LineWidth(*arg, **kw) }
    assert_equal a.(10), t.(10)
    assert_equal a.(20), t.(line_width: 20)
    assert_equal a.(30), t.(width: 30)
    assert_raises(StandardError) { t.() }
    assert_raises(StandardError) { t.(height: 10) }
  end

  def test_LineStyle
    a = lambda {|*arg, **kw| AlotPDF::LineStyle.new(*arg, **kw) }
    t = lambda {|*arg, **kw| LineStyle(*arg, **kw) }
    assert_equal a.(nil, nil, nil), t.()
    assert_equal a.(nil, nil, nil), t.(:solid)
    assert_raises(StandardError) { t.("solid") }
  end

  def test_Color
    a = lambda {|*arg, **kw| AlotPDF::Color.new(*arg, **kw) }
    t = lambda {|*arg, **kw| Color(*arg, **kw) }
    assert_equal a.(10, 20, 30), t.(10, 20, 30)
    assert_equal a.(10, 20, 30), t.(10.0, 20.5, Rational(30, 1))
    assert_equal a.(255, 96, 32), t.("ff6020")
    assert_equal a.(255, 96, 32), t.("#ff6020")
    assert_raises(StandardError) { t.("ff20g0") }
  end

  def test_Stroke
    a = lambda {|*arg, **kw| AlotPDF::Stroke.new(*arg, **kw) }
    t = lambda {|*arg, **kw| Stroke(*arg, **kw) }
    w = AlotPDF::LineWidth.new(5)
    s = AlotPDF::LineStyle.new(10, 4, 1)
    c = AlotPDF::Color.new(7, 8, 9)
    assert_equal a.(nil, nil, nil), t.(nil, nil, nil)
    assert_equal a.(w, s, c), t.(w, s, c)
    assert_raises(StandardError) { t.() }
  end
end