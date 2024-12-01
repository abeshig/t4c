require 'prawn'

class AlotPDF::Driver::Prawn
  def initialize()
    @doc = Prawn::Document.new(skip_page_creation: true)
  end

  def save_as(filename)
    @doc.render_file(filename)
  end

  def new_page()
    @doc.start_new_page()
    page_box()
  end

  def page_box()
    bounds = @doc.bounds
    AlotPDF::Box.new(nil, self, bounds.left, bounds.top, bounds.width, bounds.height)
  end

  def stroke_bounds(box, ltrb, stroke)
    @doc.line_width = AlotPDF::LineWidth.new(stroke.line_width).to_i
    style = AlotPDF::LineStyle.new(stroke.line_style)
    if style.dash.nil?
      @doc.undash
    else
      @doc.dash(style.dash, space: style.space, phase: style.phase)
    end
    @doc.stroke do
      # TODO
      # 有効な場所により、描画方法を変える。
      # 一筆書きできるところは、一筆書きをする。
      if ltrb[0]
        @doc.line [box.left, box.top], [box.left, box.top - box.height]
      end
      if ltrb[1]
        @doc.line [box.left, box.top], [box.left + box.width, box.top]
      end
      if ltrb[2]
        @doc.line [box.left + box.width, box.top], [box.left + box.width, box.top - box.height]
      end
      if ltrb[3]
        @doc.line [box.left, box.top - box.height], [box.left + box.width, box.top - box.height]
      end
    end
    self
  end

  def text(data:, left:, top:, width:, height:, font:, size:, align:, valign:)
    @doc.font(font)
    @doc.font_size(size)
    @doc.text_box(data, at: [left, top], width:, height:, align:, valign:)
  end
end