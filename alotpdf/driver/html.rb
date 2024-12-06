require 'stringio'
require 'cgi'

class AlotPDF::Driver::Html
  using AlotPDF

  class Page
    using AlotPDF

    def initialize
      @width = 211.mm
      @height = 297.mm
      @children = []
    end
    attr_reader :width, :height, :children

    def to_x(v)
      v
    end

    def to_y(v)
      @height - v
    end

    def render(out)
      out.puts "<div style='width: #{@width.to_f}pt; height: #{@height.to_f}pt; position: relative'>"
      out.puts @children.join
      out.puts '</div>'
    end
  end

  def initialize()
    @pages = []
  end

  def save_as(filename)
    filename = filename.to_s
    buf = <<END_OF_TEXT
<!DOCTYPE html>
<html>
<head>
<style>
@page {
  margin: 0mm;
  size: A4 portrait;
}
</style>
</head>
<body>
END_OF_TEXT
    out = StringIO.new(buf)
    @pages.each { _1.render(out) }
    out.puts '</body>'
    out.puts '</html>'
    out.close
    IO.write(filename.delete_suffix(File.extname(filename)) + ".html", buf)
  end

  def new_page()
    @page = Page.new
    @pages << @page
    page_box()
  end

  def page_box()
    AlotPDF::Box.new(nil, self, 0, @page.height, @page.width, @page.height)
  end

  def stroke_bounds(box, bounds, stroke)
    css = {
      position: "absolute",
      left: "#{@page.to_x(box.left).to_f}pt",
      top: "#{@page.to_y(box.top).to_f}pt",
      width: "#{box.width.to_f}pt",
      height: "#{box.height.to_f}pt",
    }
    AlotPDF::Bounds.members.zip(bounds.to_a).filter { _1[1] }.map { _1[0] }.each do
      style = "none"
      if stroke.line_style == AlotPDF::LineStyle::Builtin[:solid]
        style = "solid"
      elsif stroke.line_style == AlotPDF::LineStyle::Builtin[:dashed]
        style = "dashed"
      elsif stroke.line_style == AlotPDF::LineStyle::Builtin[:dotted]
        style = "dotted"
      else
        style = "solid"
      end
      css["border-#{_1}"] = "#{style} #{stroke.line_width.to_f}pt"
    end
    css = css.to_a.map { "#{_1}: #{_2}" }
    @page.children << "<div style='#{css.join("; ")}'></div>"
  end

  def text(data:, left:, top:, width:, height:, font:, size:, align:, valign:)
    outer_css = {
      position: "absolute",
      display: "flex",
      left: "#{@page.to_x(left).to_f}pt",
      top: "#{@page.to_y(top).to_f}pt",
      width: "#{width.to_f}pt",
      height: "#{height.to_f}pt",
    }
    inner_css = {
      width: "100%",
      "text-align": align,
      "font-size": "#{size.to_f}pt",
    }
    case valign
    when :center
      inner_css["align-self"] = "center"
    when :top
      inner_css["align-self"] = "start"
    when :bottom
      inner_css["align-self"] = "end"
    end
    outer_css = outer_css.to_a.map { "#{_1}: #{_2}" }
    inner_css = inner_css.to_a.map { "#{_1}: #{_2}" }
    @page.children << (
      "<div style='#{outer_css.join("; ")}'>" + 
      "<div style='#{inner_css.join("; ")}'>" + CGI.escape_html(data) + "</div>" +
      "</div>")
  end
end