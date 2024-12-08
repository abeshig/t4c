require 'stringio'
require 'cgi'
require 'nokogiri'

class AlotPDF::Driver::Html
  using AlotPDF

  module Length
    module_function
    def pt(n)
      n = n.to_f.floor(2)
      ni = n.to_i
      (n - ni).zero? ? "#{ni}pt" : "#{n}pt"
    end
  end

  class Page
    using AlotPDF

    def initialize
      @width = 211.mm
      @height = 297.mm
      @children = []
      @commands = []
    end
    attr_reader :width, :height, :children, :commands

    def to_x(v)
      v
    end

    def to_y(v)
      @height - v
    end
  end

  def initialize()
    @pages = []
  end

  def save_as(filename)
    pages = @pages
    html = Nokogiri::HTML::Builder.new do
      html_ do
        head do
          style do
            text <<END
@page {
  margin: 0mm;
  size: A4 portrait;
}
END
          end
        end
        body do
          pages.each do |page|
            div(style: "width: #{Length.pt(page.width)}; height: #{Length.pt(page.height)}; position: relative") do |b|
              page.commands.each do |c|
                c.(b)
              end
            end
          end
        end
      end
    end
    IO.write(filename.delete_suffix(File.extname(filename)) + ".html", html.to_html)
  end

  def new_page()
    @page = Page.new
    @pages << @page
    page_box()
  end

  def page_box()
    AlotPDF::Box.new(nil, self, 0, @page.height, @page.width, @page.height)
  end

  module CSS
    module_function
    def attr(style)
      style.to_a.map { "#{_1}: #{_2}"}.join('; ')
    end

    def box(box, page)
      {
        left: Length.pt(box.left),
        top: Length.pt(page.height - box.top),
        width: Length.pt(box.width),
        height: Length.pt(box.height),
      }
    end

    def border(bounds, stroke)
      if bounds.none?
        {border: "none"}
      else
        stroke = [
          stroke.line_width&.then { Length.pt(_1) },
          stroke.line_style&.then {
            if _1.dash.nil?
              "solid"
            elsif _1.dash <= 1
              "dotted"
            else
              "dashed"
            end
          },
          stroke.color&.then { "##{_1}" },
        ].compact.join(' ')
        if bounds.all?
          {border: stroke}
        else
          AlotPDF::Bounds.members.map do |name|
            [:"border-#{name}", bounds[name] ? stroke : "none"]
          end.to_h
        end
      end
    end

    def font(font, size)
      font = nil if font.nil? || font.empty?
      {font: [
        size&.then { Length.pt(_1) },
        font&.map { "\"#{_1}\"" }&.join(','),
      ].compact.join(' ')}
    end
  end

  def stroke_bounds(box, bounds, stroke)
    @page.commands << lambda {|b|
      styles = { position: "absolute" }
      styles.merge! CSS.box(box, @page)
      styles.merge! CSS.border(bounds, stroke)
      b.div(style: CSS.attr(styles)) {}
    }
  end

  def text(data:, box:, font:, size:, align:, valign:)
    @page.commands << lambda {|b|
      styles = { position: "absolute", display: "flex" }
      styles.merge! CSS.box(box, @page)
      styles.merge! CSS.font(font, size)
      b.div(style: CSS.attr(styles)) do
        styles = {width: "100%", "text-align": align.to_s}
        styles[:"align-self"] = {center: "center", top: "start", bottom: "end"}[valign]
        b.div(style: CSS.attr(styles)) { text data }
      end
    }
  end
end