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
    assert_equal AlotPDF::LineStyle::Builtin[:solid], t.(:solid)
    assert_equal AlotPDF::LineStyle::Builtin[:solid], t.("solid")
    assert_equal AlotPDF::LineStyle::Builtin[:dashed], t.(:dashed)
    assert_equal AlotPDF::LineStyle::Builtin[:dashed], t.(:dashed)
    assert_equal AlotPDF::LineStyle::Builtin[:dotted], t.("dotted")
    assert_equal AlotPDF::LineStyle::Builtin[:dotted], t.("dotted")
    assert_equal a.(5, 3, nil, :butt, :miter), t.(dash: 5, space: 3)
    assert_equal a.(5, 3, nil, :round, :miter), t.(dash: 5, space: 3, cap: :round)
    assert_equal a.(nil, nil, nil, :butt, :bevel), t.(join: :bevel)
    assert_raises(StandardError) { t.() }
    assert_raises(StandardError) { t.(:solid, :dashed) }
    assert_raises(StandardError) { t.(:solid, dash: 5) }
    assert_raises(StandardError) { t.(dash: 5, space: 3, plus_one: 3) }
    assert_raises(StandardError) { t.(cap: :butttt) }
    assert_raises(StandardError) { t.(join: :mittter) }
  end

  def test_Color
    a = lambda {|*arg, **kw| AlotPDF::Color.new(*arg, **kw) }
    t = lambda {|*arg, **kw| Color(*arg, **kw) }
    assert_equal a.(10, 20, 30), t.(10, 20, 30)
    assert_equal a.(10, 20, 30), t.(10.0, 20.5, Rational(30, 1))
    assert_equal a.(255, 96, 32), t.("ff6020")
    assert_equal a.(255, 96, 32), t.("#ff6020")
    assert_equal a.(255, 102, 34), t.("f62")
    assert_equal a.(255, 102, 34), t.("#f62")
    assert_equal AlotPDF::Color::Builtin[:black], t.(:black)
    assert_equal AlotPDF::Color::Builtin[:black], t.("black")
    assert_equal AlotPDF::Color::Builtin[:white], t.(:white)
    assert_equal AlotPDF::Color::Builtin[:white], t.("white")
    assert_raises(StandardError) { t.("ff20g0") }
    assert_raises(StandardError) { t.() }
    assert_raises(StandardError) { t.(10, 20) }
    assert_raises(StandardError) { t.(10, 20, 30, 40) }
    assert_raises(StandardError) { t.(10, 20, 30, r: 20, g: 30, b: 40) }
  end

  def test_Stroke
    a = lambda {|*arg, **kw| AlotPDF::Stroke.new(*arg, **kw) }
    t = lambda {|*arg, **kw| Stroke(*arg, **kw) }
    lw, ls, c = AlotPDF::LineWidth, AlotPDF::LineStyle, AlotPDF::Color
    lsb, cb = ls::Builtin, c::Builtin
    assert_equal a.(lw.new(5), nil, nil), t.(5)
    assert_equal a.(lw.new(5), nil, nil), t.(AlotPDF::LineWidth.new(5))
    assert_equal a.(nil, lsb[:solid], nil), t.(:solid)
    assert_equal a.(nil, lsb[:solid], nil), t.(AlotPDF::LineStyle::Builtin[:solid])
    assert_equal a.(nil, nil, cb[:black]), t.("black")
    assert_equal a.(nil, nil, cb[:black]), t.(AlotPDF::Color::Builtin[:black])
    assert_equal a.(nil, lsb[:solid], cb[:black]), t.(:solid, :black)
    assert_equal a.(lw.new(3), nil, c.new(17, 34, 17)), t.(3, "#121")
    assert_equal a.(lw.new(2), lsb[:dashed], cb[:white]), t.(:white, 2, :dashed)
    assert_raises(StandardError) { t.(:ssolid) }
    assert_raises(StandardError) { t.(5, line_width: AlotPDF::LineWidth.new(10)) }
  end
end