require_relative 'alotpdf.rb'
require_relative 'alotpdf/driver/prawn.rb'
require_relative 'helper.rb'
require 'date'

start = Date.parse(ARGV[0])
days = NaturalNumber.parse(ARGV[1])
filename = "#{start.strftime("%Y%m%d")}-#{start.next_day(days).strftime("%Y%m%d")}.pdf"

module Worksheet
  using AlotPDF

  def render_worksheet(page)
    page.font = "ipamp.ttf"
    header, body = page.margin(20.mm).vertical_split(30.mm, 0)
    date, title, score = header.horizontal_split(3/10, 0, 2/10)
    header.stroke_bounds
    title.stroke_bounds :left
    score.stroke_bounds :left

    today, limit = date.vertical_split(1/3, 0)
    today.text "#{work_date}", size: 12, align: :center, valign: :center

    limits = limit.horizontal_split(0, 0)
    limits[0] = limits[0].vertical_split(1/3, 0)
    limits[0][0].text "制限時間", size: 10, align: :center, valign: :center
    limits[0][1].text "#{work_limit}", size: 12, align: :center, valign: :center
    limits[1].stroke_bounds :left
    limits[1] = limits[1].vertical_split(1/3, 0)
    limits[1][0].text "所要時間", size: 10, align: :center, valign: :center

    title.text "#{work_title}", size: 12, align: :center, valign: :center

    score.margin(1.mm).text "SCORE", size: 10, align: :left, valign: :top

    render_contents(body.margin(top: 10.mm))
  end
end

class Sans_Sum1
  using AlotPDF
  include Worksheet

  def initialize(date:)
    @work_date = date
  end
  attr_reader :work_date

  def work_limit
    "3分"
  end

  def work_title
    "1桁の足し算"
  end

  def render_contents(main)
    questions = (1..9).each.to_a.permutation(2).to_a.shuffle
    main.horizontal_split(1/3, 1/3, 1/3).each_with_index do |col, colnum|
      col.vertical_split(*([1/24]*24), gap: 2.mm).each_with_index do |row, rownum|
        i = colnum*24 + rownum
        qary = questions[i]
        qstr = "#{qary[0]} + #{qary[1]} ="
        num, q = row.horizontal_split(10.mm, 0)
        num.text "#{i+1}.", size: 12, align: :left, valign: :center
        q.text qstr, size: 12, align: :left, valign: :center
      end
    end
    self
  end
end

pdf = AlotPDF::Driver::Prawn.new
start.upto(start.next_day(days)) do |date|
  Sans_Sum1.new(date:).render_worksheet(pdf.new_page)
end
pdf.save_as(filename)