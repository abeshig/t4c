require 'date'
require_relative 'helper.rb'

module Application
end

class Application::LeveledDailyWork
  def initialize(*args, id: "")
    @level = NaturalNumber.parse(args.shift)
    for arg in args do
      case arg
      when /^\d{1,2}$/
        raise if @days
        @days = NaturalNumber.parse(arg)
      when /^(\d{8}|\d{4}\/\d{1,2}\/\d{1,2}|\d{4}-\d{1,2}-\d{1,2})$/
        raise if @start
        @start = Date.parse(arg)
      when /^(pdf|html)$/i
        raise if @format
        @format = arg.downcase
      else
        raise "invalid parameter: #{arg}"
      end
    end
    @start ||= Date.today
    @days ||= 1
    @id = id
  end
  attr_reader :level, :start, :days, :format, :id

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

  def html?
    self.format == 'html'
  end

  def pdf?
    self.format == 'pdf'
  end
end

class Application::Template
  def to_proc
    self.method(:render).to_proc
  end
end