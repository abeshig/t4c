module PageTemplate
end

class PageTemplate::Worksheet < Application::Template
  using AlotPDF
  attr_accessor :title, :limit, :date, :content
  attr_accessor :page_font

  def render(page)
    page.font = page_font if page_font
    header, body = page.margin(20.mm).vertical_split(30.mm, 0)
    date, title, score = header.horizontal_split(3/10, 0, 2/10)
    header.stroke_bounds
    title.stroke_bounds :left
    score.stroke_bounds :left

    today, limit = date.vertical_split(1/3, 0)
    today.text self.date.to_s, size: 12, align: :center, valign: :center

    limits = limit.horizontal_split(0, 0)
    limits[0] = limits[0].vertical_split(1/3, 0)
    limits[0][0].text "制限時間", size: 10, align: :center, valign: :center
    limits[0][1].text self.limit.to_s, size: 12, align: :center, valign: :center
    limits[1].stroke_bounds :left
    limits[1] = limits[1].vertical_split(1/3, 0)
    limits[1][0].text "所要時間", size: 10, align: :center, valign: :center

    title.text self.title.to_s, size: 12, align: :center, valign: :center

    score.margin(1.mm).text "SCORE", size: 10, align: :left, valign: :top

    self.content.to_proc.call(body.margin(top: 10.mm))
  end
end

class PageTemplate::IndexedQuestions < Application::Template
  using AlotPDF

  def initialize()
    @cols = 1
    @questions = []
    @col_gap = 0
    @row_gap = 0
  end
  attr_accessor :cols, :questions, :col_gap, :row_gap, :question_renderer
  attr_accessor :index_font, :question_font

  def render(box)
    cols = @cols.floor
    rows = (@questions.size / cols).ceil
    box.horizontal_split(*([0] * cols), gap: @col_gap).each_with_index do |hbox, col|
      hbox.vertical_split(*([0] * rows), gap: @row_gap).each_with_index do |vbox, row|
        i = col * rows + row
        next if i >= @questions.size
        if @question_renderer
          @question_renderer.call(vbox, @questions, i)
        else
          nbox, qbox = vbox.horizontal_split(10.mm, 0)
          nbox.text "#{i+1}.", size: 12, align: :left, valign: :center, font: index_font
          qbox.text @questions[i], size: 12, align: :left, valign: :center, font: question_font
        end
      end
    end
  end
end