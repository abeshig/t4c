require 'minitest/autorun'
require_relative '../pdf.rb'
require_relative 'html.rb'

class TestHtml < Minitest::Test
  include AlotPDF::Helper

  def test_box()
    t = lambda {|*arg, **kw| AlotPDF::Driver::Html::CSS.box(*arg, **kw) }
    page = AlotPDF::Box.new(left: 0, top: 0, width: 200, height: 300)

    assert_equal({left: "10pt", top: "20pt", width: "30pt", height: "40pt"},
      t.(AlotPDF::Box.new(left: 10, top: 280, width: 30, height: 40), page))

    assert_equal({left: "10.5pt", top: "50pt", width: "29.33pt", height: "40.66pt"},
      t.(AlotPDF::Box.new(left: 10.5, top: 250, width: 29.33333, height: 40.6666), page))
  end

  def test_border()
    t = lambda {|*arg, **kw| AlotPDF::Driver::Html::CSS.border(*arg, **kw) }

    assert_equal({border: "none"}, t.(Bounds(false), Stroke(:solid)))
    assert_equal({border: "solid"}, t.(Bounds(true), Stroke(:solid)))
    assert_equal({
      "border-left": "solid", "border-top": "none",
      "border-right": "solid", "border-bottom": "none",
    }, t.(Bounds(false, true), Stroke(:solid)))
    assert_equal({
      "border-left": "3pt dashed #FF1256",
      "border-top": "none",
      "border-right": "none",
      "border-bottom": "3pt dashed #FF1256",
    }, t.(Bounds(true, false, false, true), Stroke(:dashed, 3, "ff1256")))
  end

end