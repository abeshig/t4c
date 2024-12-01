AlotPDF::Point = Struct.new(:x, :y) do
  def initialize(*arg, **kw)
    case arg
    in [AlotPDF::Point]
      super(*arg[0].to_a)
    in [Array]
      super(*arg[0])
    in [Hash]
      super(**arg[1])
    else
      super(*arg, **kw)
    end
  end

  def to_s
    "#{x},#{y}"
  end
end

AlotPDF::Size = Struct.new(:width, :height) do
  def initialize(*arg, **kw)
    case arg
    in [AlotPDF::Size]
      super(*arg[0].to_a)
    in [Array]
      super(*arg[0])
    in [Hash]
      super(**arg[0])
    else
      super(*arg, **kw)
    end
  end

  def to_s
    "#{width}x#{height}"
  end
end

AlotPDF::LineWidth = Struct.new(:line_width) do
  def initialize(*arg, **kw)
    case arg
    in [AlotPDF::LineWidth]
      super(*arg[0].to_a)
    in [Array]
      super(*arg[0])
    in [Hash]
      super(**arg[0])
    else
      super(*arg, **kw)
    end
  end

  def to_i
    line_width.to_i
  end

  def to_int
    to_i
  end
end

# - :cap
#   - :butt (default)
#   - :round
#   - :projecting_square
# - :join
#   - :miter (default)
#   - :round
#   - :bevel
AlotPDF::LineStyle = Struct.new(:dash, :space, :phase, :cap, :join) do
  def initialize(*arg, **kw)
    case arg
    in [AlotPDF::LineStyle]
      super(*arg[0].to_a)
    in [Array]
      super(*arg[0])
    in [Hash]
      super(**arg[0])
    else
      super(*arg, **kw)
    end
  end
end

AlotPDF::Color = Struct.new(:red, :green, :blue) do
  def initialize(*arg, **kw)
    case arg
    in [AlotPDF::Color]
      super(*arg[0].to_a)
    in [Array]
      super(*arg[0])
    in [Hash]
      super(**arg[0])
    else
      super(*arg, **kw)
    end
  end

  def to_s
    to_a.map { _1.to_i.to_s(16).rjust('0')[-2..-1] }.join('').upcase
  end
end

AlotPDF::Stroke = Struct.new(:line_width, :line_style, :color) do
  def initialize(*arg, **kw)
    case arg
    in [AlotPDF::Stroke]
      super(*arg[0].to_a)
    in [Array]
      super(*arg[0])
    in [Hash]
      super(**arg[0])
    else
      super(*arg, **kw)
    end
  end
end
