require 'minitest/autorun'
require_relative 'app.rb'

class TestLeveledDailyWork < Minitest::Test
  T = Application::LeveledDailyWork

  def test_filename
    assert_equal "t-20240105-20240110", T.new('1', '2024/1/5', '6', id: "t").filename
    assert_equal "t-20240105", T.new('1', '20240105', '1', id: "t").filename
  end

  def test_each_day
    t = T.new('1', '2024/2/3', '4')
    a = []
    t.each_day { a << _1.strftime("%Y%m%d") }
    assert_equal ["20240203", "20240204", "20240205", "20240206"], a

    a = t.each_day.to_a.map { _1.strftime("%Y%m%d") }
    assert_equal ["20240203", "20240204", "20240205", "20240206"], a

    t = T.new('1', '2024/2/3', '1')
    a = []
    t.each_day { a << _1.strftime("%Y%m%d") }
    assert_equal ["20240203"], a
  end

  def test_new
    t = T.new('3', '20240203', '7')
    assert_equal t.level, 3
    assert_equal t.start, Date.new(2024, 2, 3)
    assert_equal t.days, 7
    assert_nil t.format

    t = T.new('1', '2024/2/3', '1')
    assert_equal t.level, 1
    assert_equal t.start, Date.new(2024, 2, 3)
    assert_equal t.days, 1
    assert_nil t.format

    t = T.new('1', '2024-2-3', '10')
    assert_equal t.level, 1
    assert_equal t.start, Date.new(2024, 2, 3)
    assert_equal t.days, 10
    assert_nil t.format

    t = T.new('1', '2024-02-3', '10', 'html')
    assert_equal t.level, 1
    assert_equal t.start, Date.new(2024, 2, 3)
    assert_equal t.days, 10
    assert_equal t.format, 'html'

    t = T.new('1', '2024-2-03', '10', 'HTML')
    assert_equal t.level, 1
    assert_equal t.start, Date.new(2024, 2, 3)
    assert_equal t.days, 10
    assert_equal t.format, 'html'

    assert_raises { T.new() }
    assert_raises { T.new('high') }
    assert_raises { T.new('10', '10', '10') }
    assert_raises { T.new('10', '20241110', '2024/4/20') }
    assert_raises { T.new('10', 'today') }
    assert_raises { T.new('10', 'hhtml') }
  end

  def test_format
    t = T.new('1', 'html')
    assert_equal true, t.html?
    assert_equal false, t.pdf?

    t = T.new('10', 'HTML')
    assert_equal true, t.html?
    assert_equal false, t.pdf?

    t = T.new('10', 'pdf')
    assert_equal false, t.html?
    assert_equal true, t.pdf?

    t = T.new('10', 'PDF')
    assert_equal false, t.html?
    assert_equal true, t.pdf?
  end
end