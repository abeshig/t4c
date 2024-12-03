AlotPDF::Point = Struct.new(:x, :y) do
  def to_s
    "#{x},#{y}"
  end
end

AlotPDF::Size = Struct.new(:width, :height) do
  def to_s
    "#{width}x#{height}"
  end
end

AlotPDF::LineWidth = Struct.new(:line_width) do
  def to_i
    line_width.to_i
  end
end

AlotPDF::LineStyle = Struct.new(:dash, :space, :phase, :cap, :join) do
  def valid_cap?
    AlotPDF::LineStyle::Caps.include?(cap)
  end

  def valid_join?
    AlotPDF::LineStyle::Joins.include?(join)
  end
end
class AlotPDF::LineStyle
  Builtin = {
    solid: AlotPDF::LineStyle.new(nil, nil, nil, :butt, :miter).freeze,
    dashed: AlotPDF::LineStyle.new(3, 3, 0, :butt, :miter).freeze,
    dotted: AlotPDF::LineStyle.new(1, 1, 0, :butt, :miter).freeze,
  }.freeze
  Caps = [:butt, :round, :projecting_square].freeze
  Joins = [:miter, :round, :bevel].freeze
end

AlotPDF::Color = Struct.new(:red, :green, :blue) do
  def to_s
    to_a.map { _1.to_i.to_s(16).rjust('0')[-2..-1] }.join('').upcase
  end
end
class AlotPDF::Color
  Builtin = {
    black: AlotPDF::Color.new(0, 0, 0),
    white: AlotPDF::Color.new(255, 255, 255),
  }.freeze
end

AlotPDF::Stroke = Struct.new(:line_width, :line_style, :color) do
end

AlotPDF::Bounds = Struct.new(:left, :top, :right, :bottom) do
  def to_s
    (left ? "L" : "_") + (top ? "T" : "_") + (right ? "R" : "_") + (bottom ? "B" : "_")
  end
end