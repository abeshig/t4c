require_relative 'helper.rb'
require 'date'

start = Date.parse(ARGV[0])
days = NaturalNumber.parse(ARGV[1])
filename = "#{start.strftime("%Y%m%d")}-#{start.next_day(days).strftime("%Y%m%d")}.pdf"

require "prawn"
require "prawn/measurement_extensions"

def start_worksheet(pdf, date: nil, limit: nil, title: "", &block)
  render_date = proc do
    t = date.strftime("%Y/%m/%d")
    if limit
      t += "\n<font size='10'>制限時間 #{limit}</font>"
    end
    font "ipamp.ttf"
    text_box t, at: [0, bounds.height],
      size: 12,
      width: bounds.width, height: bounds.height,
      align: :center, valign: :center,
      inline_format: true
  end
  render_title = proc do
    font "ipamp.ttf"
    text_box title, at: [0, bounds.height],
      size: 12,
      width: bounds.width, height: bounds.height,
      align: :center, valign: :center
  end
  render_score = proc do
    font "ipamp.ttf"
    text_box "SCORE", at: [1.mm, bounds.height - 1.mm],
      size: 12, 
      width: bounds.width - 2.mm, height: bounds.height - 2.mm,
      align: :left, valign: :top
  end
  render_box = proc do
    stroke_bounds
    x1, x2 = bounds.width * 2 / 10, bounds.width * 8 / 10
    stroke do
      line [x1, 0], [x1, bounds.height]
      line [x2, 0], [x2, bounds.height]
    end
    bounding_box([0, bounds.height], width: x1, height: bounds.height) do
      pdf.instance_eval(&render_date)
    end
    bounding_box([x1, bounds.height], width: x2 - x1, height: bounds.height) do
      pdf.instance_eval(&render_title)
    end
    bounding_box([x2, bounds.height], width: bounds.width - x2, height: bounds.height) do
      pdf.instance_eval(&render_score)
    end
  end
  pdf.instance_eval do
    start_new_page margin: 20.mm, size: "A4", layout: :portrait
    y = bounds.height
    bounding_box([0, y], width: bounds.width, height: 25.mm) do
      pdf.instance_eval(&render_box)
    end
    y -= 25.mm + 5.mm
    bounding_box([0, y], width: bounds.width, height: y) do
      pdf.instance_eval(&block) if block
    end
  end
  return pdf
end

def render_sans_sum1(pdf)
  questions = (1..10).each.to_a.permutation(2).to_a.shuffle
  pdf.instance_eval do
    w, h = bounds.width, bounds.height
    (0...3).each do |i|
      bounding_box([i * w / 3, h], width: w/3, height: h) do
        hh = bounds.height
        (0...27).each do |j|
          bounding_box([0, hh * (27-j)/27], width: bounds.width, height: hh/27) do
            bounding_box([0, bounds.height], width: 1.cm, height: bounds.height) do
              text "#{j+i*27+1}.", valign: :center
            end
            bounding_box([1.cm, bounds.height], width: bounds.width - 1.cm, height: bounds.height) do
              q = questions[j+i*27]
              s = "#{q[0]} + #{q[1]} ="
              text s, valign: :center
            end
            bounding_box([3.cm, bounds.height], width: 1.cm, height: bounds.height) do
              stroke_bounds
            end
          end
        end
      end
    end
  end
end

pdf = Prawn::Document.new(skip_page_creation: true)
start.upto(start.next_day(days)) do |d|
  start_worksheet(pdf, date: d, title: "1桁の足し算", limit: "3分") do
    render_sans_sum1(pdf)
  end
end
pdf.render_file(filename)
