require 'minitest/autorun'
require_relative 'pdf.rb'
require_relative 'driver/test.rb'

class TestBoxMargin < Minitest::Test
  include AlotPDF::Box::Margin
  using AlotPDF

  def test_getLTRB
    test = MarginHelper.singleton_method(:getLTRB)
    assert_equal [5, 5, 5, 5], test.(5)
    assert_equal [4, 2, 4, 2], test.(2, 4)
    assert_equal [1, 2, 3, 4], test.(1, 2, 3, 4)
    assert_equal [4, 0, 0, 0], test.(left: 4)
    assert_equal [0, 5, 0, 0], test.(top: 5)
    assert_equal [0, 0, 6, 0], test.(right: 6)
    assert_equal [0, 0, 0, 7], test.(bottom: 7)
    assert_equal [4, 5, 0, 0], test.(left: 4, top: 5)
    assert_equal [0, 0, 6, 7], test.(right: 6, bottom: 7)
  end

  def test_margin
    driver = AlotPDF::Driver::Test.new(width: 300, height: 200)
    box = driver.new_page
    t = lambda {|*arg, **kw| box.margin(*arg, **kw) }
    assert_equal AlotPDF::Box.new(box, driver, 10, 180, 280, 160), t.(20, 10)
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