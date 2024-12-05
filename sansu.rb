
require_relative 'alotpdf.rb'
require_relative 'alotpdf/driver/prawn.rb'
require_relative 'helper.rb'
require_relative 'app.rb'
require_relative 'page.rb'
require 'date'

using AlotPDF

app = Application::LeveledDailyWork.new(*ARGV, id: "sans")

def generate_pair_generator(range)
  lambda {
    range.each.to_a.permutation(2).to_a.shuffle 
  }
end

Works = {
  1 => {
    title: "1桁の足し算",
    limit: "3分",
    question_generator: generate_pair_generator(1..9),
    question_string: proc { "#{_1} + #{_2} =" },
    answer_string: proc { _1 + _2 },
  },
  2 => {
    title: "1桁の引き算",
    limit: "3分",
    question_generator: generate_pair_generator(1..9),
    question_string: proc { "#{_1 + _2} - #{_2} =" },
    answer_string: proc { _1[0] },
  },
  3 => {
    title: "1桁の足し算と引き算",
    limit: "3分",
    question_generator: proc {
      sums = generate_pair_generator(1..9).().map { [*_1, 0] }
      subs = generate_pair_generator(1..9).().map { [*_1, 1] }
      (sums + subs).shuffle[0...72]
    },
    question_string: proc {
      case _3
      when 0
        "#{_1} + #{_2} ="
      when 1
        "#{_1 + _2} - #{_2} ="
      end
    },
    answer_string: proc {
      case _3
      when 0
        _1 + _2
      when 1
        _1
      end
    },
  },
  4 => {
    title: "1桁のかけ算",
    limit: "3分",
    question_generator: generate_pair_generator(1..9),
    question_string: proc { "#{_1} ✕ #{_2} =" },
    answer_string: proc { _1 * _2 },
  },
}
work = Works[app.level]
exit(-1) if work.nil?

pdf = AlotPDF::Driver::Prawn.new
app.each_day do |date|
  qary = work[:question_generator].()

  qs = PageTemplate::IndexedQuestions.new
  qs.cols = 3
  qs.col_gap = 10.mm
  qs.row_gap = 1.mm
  qs.questions = qary.map { work[:question_string].(*_1) }

  ws = PageTemplate::Worksheet.new
  ws.title = work[:title]
  ws.limit = work[:limit]
  ws.date = date.strftime("%Y/%m/%d")
  ws.content = qs

  ws.render(pdf.new_page)
end
pdf.save_as(app.filename)