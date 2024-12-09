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
end