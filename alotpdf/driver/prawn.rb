require 'prawn'

class AlotPDF::Driver::Prawn
  def initialize()
    @doc = Prawn::Document.new(skip_page_creation: true)
    @fontlib = AlotPDF::Helper::FontLibrary.detect_fonts("./fonts")
    @errors = []
  end
  attr_accessor :errors

  def save_as(filename)
    filename = filename.to_s
    ext = File.extname(filename)
    @doc.render_file(filename.delete_suffix(ext) + ".pdf")
  end

  def new_page()
    @doc.start_new_page(page_size: 'A4', margin: 0)
    page_box()
  end

  def page_box()
    bounds = @doc.bounds
    AlotPDF::Box.new(nil, self, bounds.left, bounds.top, bounds.width, bounds.height)
  end

  def stroke_bounds(box, bounds, stroke)
    @doc.line_width = stroke.line_width.to_i
    style = stroke.line_style
    if style.dash.nil?
      @doc.undash
    else
      @doc.dash(style.dash, space: style.space, phase: style.phase)
    end
    @doc.stroke do
      # TODO
      # 有効な場所により、描画方法を変える。
      # 一筆書きできるところは、一筆書きをする。
      if bounds.left
        @doc.line [box.left, box.top], [box.left, box.top - box.height]
      end
      if bounds.top
        @doc.line [box.left, box.top], [box.left + box.width, box.top]
      end
      if bounds.right
        @doc.line [box.left + box.width, box.top], [box.left + box.width, box.top - box.height]
      end
      if bounds.bottom
        @doc.line [box.left, box.top - box.height], [box.left + box.width, box.top - box.height]
      end
    end
    self
  end

  def text(data:, box:, font:, size:, align:, valign:)
    if font
      if @fontlib.has_key?(font)
        @doc.font(@fontlib[font])
      else
        @doc.font(font)
      end
    end
    if size
      @doc.font_size(size)
    end
    @doc.text_box(data, at: [box.left, box.top], width: box.width, height: box.height, align:, valign:)
  end
end