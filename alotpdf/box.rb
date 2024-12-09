AlotPDF::Box = Struct.new(:parent, :driver, :left, :top, :width, :height) do

  def initialize(*arg, **kw)
    super(*arg, **kw)
    if parent.nil?
      @font = nil
      @fontsize = 12
      @stroke = AlotPDF::Stroke.new(
        AlotPDF::LineWidth.new(1),
        AlotPDF::LineStyle.new(nil, nil, nil, :butt, :miter),
        AlotPDF::Color.new(0, 0, 0),
        )
    end
  end

  def to_s
    "{(#{left},#{top}) #{width}x#{height}}"
  end

  def size
    AlotPDF::Size.new(width, height)
  end

  def left_top
    AlotPDF::Point.new(left, top)
  end

  def font
    @font || parent&.font
  end

  def font=(font)
    @font = font
  end

  def fontsize
    @fontsize || parent.fontsize
  end

  def fontsize=(fontsize)
    @fontsize = fontsize
  end

  def stroke
    @stroke || parent.stroke
  end

  def stroke=(stroke)
    @stroke = stroke
  end

end
require_relative 'box/margin.rb'
require_relative 'box/split.rb'
require_relative 'box/stroke.rb'
require_relative 'box/text.rb'
class AlotPDF::Box
  include Margin
  include Split
  include Stroke
  include Text
end