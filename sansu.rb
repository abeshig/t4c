
require_relative 'alotpdf.rb'
require_relative 'alotpdf/driver/prawn.rb'
require_relative 'helper.rb'
require_relative 'app.rb'
require_relative 'page.rb'
require 'date'

using AlotPDF

app = Application::LeveledDailyWork.new(*ARGV, id: "sans")

def generate_pair(range)
  range.each.to_a.permutation(2).to_a.shuffle 
end
def generate_pair_generator(range)
  lambda {
    range.each.to_a.permutation(2).to_a.shuffle 
  }
end

q_sum = lambda {|a,b| [a, "+", b, "="].join(" ") }
a_sum = lambda {|a,b| a+b }
q_sub = lambda {|a,b| [a+b, "-", b, "="].join(" ") }
a_sub = lambda {|a,b| a }
q_mul = lambda {|a,b| [a, "✕", b, "="].join(" ") }
a_mul = lambda {|a,b| a*b }

Works = {
  1 => {
    title: "1桁の足し算",
    limit: "3分",
    qa_generator: proc {
      generate_pair(1..9).map {|a,b| [q_sum.(a,b), a_sum.(a,b)] }.transpose
    },
  },
  2 => {
    title: "1桁の引き算",
    limit: "3分",
    qa_generator: proc {
      generate_pair(1..9).map {|a,b| [q_sub.(a,b), a_sub.(a,b)] }.transpose
    },
  },
  3 => {
    title: "1桁の足し算と引き算",
    limit: "3分",
    qa_generator: proc {
      p1 = generate_pair(1..9).map { [_1, q_sum, a_sum] }
      p2 = generate_pair(1..9).map { [_1, q_sub, a_sub] }
      (p1+p2).shuffle[0...72].map {|pair,q,a| [q.(*pair), a.(*pair)] }.transpose
    },
  },
  4 => {
    title: "1桁のかけ算",
    limit: "3分",
    qa_generator: proc {
      generate_pair(1..9).map {|a,b| [q_mul.(a,b), a_mul.(a,b)] }.transpose
    },
  },
}
work = Works[app.level]
exit(-1) if work.nil?

pdf = AlotPDF::Driver::Prawn.new
app.each_day do |date|
  qs = PageTemplate::IndexedQuestions.new
  qs.cols = 3
  qs.col_gap = 10.mm
  qs.row_gap = 1.mm
  questions, _ = work[:qa_generator].()
  qs.questions = questions

  ws = PageTemplate::Worksheet.new
  ws.title = work[:title]
  ws.limit = work[:limit]
  ws.date = date.strftime("%Y/%m/%d")
  ws.content = qs

  ws.render(pdf.new_page)
end
pdf.save_as(app.filename)