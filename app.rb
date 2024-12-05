require 'date'
require_relative 'helper.rb'

module Application
end

class Application::LeveledDailyWork
  def initialize(level, start, days, id: "")
    @level = NaturalNumber.parse(level)
    @start = Date.parse(start)
    @days = NaturalNumber.parse(days)
    @id = id
  end
  attr_reader :level, :start, :days, :id

  def filename
    format_date = lambda {|t| t.strftime("%Y%m%d") }
    [
      id,
      format_date.(start),
      days <= 1 ? "" : format_date.(start.next_day(days-1)),
    ].delete_if { _1.empty? }.join('-')
  end

  def each_day
    return to_enum(__method__) { days } unless block_given?
    start.upto(start.next_day(days - 1)) do |date|
      yield date
    end
  end
end

class Application::Template
  def to_proc
    self.method(:render).to_proc
  end
end