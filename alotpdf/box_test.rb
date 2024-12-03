require 'minitest/autorun'
require_relative 'pdf.rb'
require_relative 'driver/test.rb'

class TestBoxMargin < Minitest::Test
  using AlotPDF

  def test_margin
    driver = AlotPDF::Driver::Test.new(width: 300, height: 200)
    box = driver.new_page

    t = lambda {|*arg, **kw| box.margin(*arg, **kw) }
    assert_equal AlotPDF::Box.new(box, driver, 10, 190, 280, 180), t.(10)
    assert_equal AlotPDF::Box.new(box, driver, 10, 180, 280, 160), t.(20, 10)
    assert_equal AlotPDF::Box.new(box, driver, 10, 180, 260, 140), t.(10, 20, 30, 40)
    assert_equal AlotPDF::Box.new(box, driver, 10, 200, 290, 200), t.(left: 10)
    assert_equal AlotPDF::Box.new(box, driver, 0, 190, 300, 190), t.(top: 10)
    assert_equal AlotPDF::Box.new(box, driver, 0, 200, 290, 200), t.(right: 10)
    assert_equal AlotPDF::Box.new(box, driver, 0, 200, 300, 190), t.(bottom: 10)
    assert_equal AlotPDF::Box.new(box, driver, 10, 175, 265, 150), t.(25, left: 10)
    assert_equal AlotPDF::Box.new(box, driver, 30, 180, 240, 160), t.(1/10)
    assert_raises(StandardError) { t.() }
    assert_raises(StandardError) { t.(10, 20, 30) }
    assert_raises(StandardError) { t.(10, 20, 30, 40, 50) }
  end
end

class TestBoxSplit < Minitest::Test
  include AlotPDF::Box::Split
  using AlotPDF

  def test_split_size
    t = lambda {|*arg, **kw| Helper.split_size(*arg, **kw) }
    assert_equal [], t.([], 600, 0)
    assert_equal [100, 100, 100], t.([100, 100, 100], 600, 0)
    assert_equal [100, 400, 100], t.([100, 0, 100], 600, 0)
    assert_equal [100, 380, 100], t.([100, 0, 100], 600, 10)
    assert_equal [100, 300, 150], t.([1/6, 3/6, 150], 600, 0)
    assert_equal [100, 200, 200], t.([1/5, 0, 0], 600, 50)
    assert_equal [100, 250, 250], t.([1/6, 0, 0], 600, 0)
  end

  def test_vertical_split
    driver = AlotPDF::Driver::Test.new(width: 300, height: 200)
    box = driver.new_page
    t = lambda {|*arg, **kw| box.vertical_split(*arg, **kw) }
    assert_equal [
      AlotPDF::Box.new(box, driver, 0, 200, 300, 100),
      AlotPDF::Box.new(box, driver, 0, 100, 300, 100),
    ], t.(1/2, 1/2)
    assert_equal [
      AlotPDF::Box.new(box, driver, 0, 200, 300, 50),
      AlotPDF::Box.new(box, driver, 0, 125, 300, 50),
      AlotPDF::Box.new(box, driver, 0, 50, 300, 50),
    ], t.(1/3, 1/3, 1/3, gap: 25)
  end

  def test_horizontal_split
    driver = AlotPDF::Driver::Test.new(width: 300, height: 200)
    box = driver.new_page
    t = lambda {|*arg, **kw| box.horizontal_split(*arg, **kw) }
    assert_equal [
      AlotPDF::Box.new(box, driver, 0, 200, 150, 200),
      AlotPDF::Box.new(box, driver, 150, 200, 150, 200),
    ], t.(1/2, 1/2)
    assert_equal [
      AlotPDF::Box.new(box, driver, 0, 200, 90, 200),
      AlotPDF::Box.new(box, driver, 105, 200, 90, 200),
      AlotPDF::Box.new(box, driver, 210, 200, 90, 200),
    ], t.(1/3, 1/3, 1/3, gap: 15)
  end
end

class TestBoxStroke < Minitest::Test
  include AlotPDF::Helper

  def test_stroke_bounds
    driver = AlotPDF::Driver::Test.new(width: 300, height: 200)
    box = driver.new_page

    box.stroke_bounds
    retbox, bounds, stroke = driver.eject_log[:stroke_bounds][0].values_at(:box, :bounds, :stroke)
    assert_equal box, retbox
    assert_equal Bounds(true), bounds
    assert_equal box.stroke, stroke

    box.stroke_bounds :left, 10
    retbox, bounds, stroke = driver.eject_log[:stroke_bounds][0].values_at(:box, :bounds, :stroke)
    assert_equal box, retbox
    assert_equal Bounds(:left), bounds
    assert_equal Stroke(10), stroke

    box.stroke_bounds :left, :right, :right, :dotted
    retbox, bounds, stroke = driver.eject_log[:stroke_bounds][0].values_at(:box, :bounds, :stroke)
    assert_equal box, retbox
    assert_equal Bounds(:left, :right), bounds
    assert_equal Stroke(:dotted), stroke

    box.stroke_bounds 10, bounds: [:left]
    retbox, bounds, stroke = driver.eject_log[:stroke_bounds][0].values_at(:box, :bounds, :stroke)
    assert_equal box, retbox
    assert_equal Bounds(:left), bounds
    assert_equal Stroke(10), stroke

    box.stroke_bounds :top, :bottom, :dashed, "#ff0"
    retbox, bounds, stroke = driver.eject_log[:stroke_bounds][0].values_at(:box, :bounds, :stroke)
    assert_equal box, retbox
    assert_equal Bounds(:top, :bottom), bounds
    assert_equal Stroke(:dashed, "#ff0"), stroke

    box.stroke_bounds :top, :bottom, Stroke(:dashed, "#ff0")
    retbox, bounds, stroke = driver.eject_log[:stroke_bounds][0].values_at(:box, :bounds, :stroke)
    assert_equal box, retbox
    assert_equal Bounds(:top, :bottom), bounds
    assert_equal Stroke(:dashed, "#ff0"), stroke

    box.stroke_bounds bounds: [:top, :bottom], stroke: [:dashed, "#ff0"]
    retbox, bounds, stroke = driver.eject_log[:stroke_bounds][0].values_at(:box, :bounds, :stroke)
    assert_equal box, retbox
    assert_equal Bounds(:top, :bottom), bounds
    assert_equal Stroke(:dashed, "#ff0"), stroke

    assert_raises(StandardError) { box.stroke_bounds 10, :tttop }
    assert_raises(StandardError) { box.stroke_bounds bounds: 100 }
  end
end