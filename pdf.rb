module PDF
end

module PDF::Helper

  refine Integer do
    def /(other)
      case other
      when Integer
        Rational(self, other)
      else
        super(self, other)
      end
    end
  end

  refine Numeric do
    def pt
      self
    end

    def mm
      # 25.4mm = 1inch = 72pt
      # 1mm = 1/25.4inch = 72/25.4pt = 720/254pt
      Rational(self * 720, 254)
    end

    def rate?
      !is_a?(Integer) && 0 < self && self < 1
    end
  end

end

class PDF::Point
  def initialize(*arg, **kw)
    @x, @y =
      case [arg, kw]
      in [PDF::Point], {}
        arg.first.to_a
      in [Numeric, Numeric], {}
        arg
      in [], {x: Numeric, y: Numeric}
        kw.values_at(:x, :y)
      end
  end
  attr_reader :x, :y

  def to_a
    [@x, @y]
  end

  def to_h
    {x: @x, y: @y}
  end

  def to_s
    "(#{@x},#{@y})"
  end
end

class PDF::Size
  def initialize(*arg, **kw)
    @width, @height =
      case [arg, kw]
      in [PDF::Size], {}
        arg.first.to_a
      in [Numeric, Numeric], {}
        arg
      in [], {width: Numeric, height: Numeric}
        kw.values_at(:width, :height)
      end
  end
  attr_reader :width, :height

  def to_a
    [@width, @height]
  end

  def to_h
    {width: @width, height: @height}
  end

  def to_s
    "#{@width}x#{@height}"
  end
end

class PDF::Box
  using PDF::Helper

  def initialize(*arg, **kw)
    ltrb = proc {|left, top, right, bottom|
      [[left, right].min, [top, bottom].max, (right - left).abs, (top - bottom).abs]
    }
    @left, @top, @width, @height =
      case [arg, kw]
      in [PDF::Box], {}
        arg[0].to_a
      in [Numeric, Numeric, Numeric, Numeric], {}
        ltrb.(*arg)
      in [PDF::Point, PDF::Size], {}
        [*arg[0], *arg[1]]
      in [PDF::Size, PDF::Point], {}
        [*arg[1], *arg[0]]
      in [Numeric, Numeric], {width: Numeric, height: Numeric}
        [arg[0], arg[1], *kw.values_at(:width, :height)]
      in [PDF::Point], {width: Numeric, height: Numeric}
        [*arg[0], *kw.values_at(:width, :height)]
      in [], {left: Numeric, top: Numeric, width: Numeric, height: Numeric}
        kw.values_at(:left, :top, :width, :height)
      in [], {x: Numeric, y: Numeric, width: Numeric, height: Numeric}
        kw.values_at(:x, :y, :width, :height)
      in [], {at: [Numeric, Numeric], width: Numeric, height: Numeric}
        [*kw[:at], *kw.values_at(:width, :height)]
      in [[], {left: Numeric, top: Numeric, right: Numeric, bottom: Numeric}]
        ltrb.(*kw.values_at(:left, :top, :right, :bottom))
      end
    @parent = kw[:parent]
  end

  def to_a
    [@left, @top, @width, @height]
  end

  def to_h
    {left: @left, top: @top, width: @width, height: @height}
  end

  def size
    PDF::Size.new(@width, @height)
  end

  def left_top
    PDF::Point.new(@left, @top)
  end

  def font
    @font || @parent&.font
  end

  def font=(font)
    @font = font
  end

  def margin(*arg, **kwarg)
    left, top, right, bottom = case [arg, kwarg]
      in [Numeric], {}
        [arg[0], arg[0], arg[0], arg[0]] 
      in [Numeric, Numeric], {}
        [arg[1], arg[0], arg[1], arg[0]]
      in [Numeric, Numeric, Numeric, Numeric], {}
        arg
      in [], {**}
        kwarg.values_at(:left, :top, :right, :bottom)
      end
    left *= @width if left.rate?
    right *= @width if right.rate?
    top *= @height if top.rate?
    bottom *= @height if bottom.rate?
    PDF::Box.new(@left+left, @top+top, @width-left-right, @height-top-bottom, parent: self)
  end

  def split_size(values, size, gap)
    return [] if values.size == 0
    values = values.dup
    size -= gap * (values.size - 1)
    values.map! {|n| n.rate? ? size * n : n }
    zero_count = values.count(0)
    if zero_count > 0
      remain = size - values.sum
      if zero_count == 1
        values[values.index(0)] = remain
      else
        remain /= zero_count
        values.map! {|n| n == 0 ? remain : n }
      end
    end
    return values
  end

  def vertical_split(*heights, gap: 0)
    heights = split_size(heights, @height, gap)
    top = @top
    heights.map do |height, n|
      PDF::Box.new(@left, top, @width, height).tap { top -= height + gap }
    end
  end

  def horizontal_split(*widths)
    widths = split_size(widths, @width, gap)
    left = @left
    widths.map do |width, n|
      PDF::Box.new(left, @top, width, @height).tap { left += width + gap }
    end
  end
end

=begin

def PDF.mm(n)
  # 25.4mm = 1inch = 72pt
  # 1mm = 1/25.4inch = 72/25.4pt = 720/254pt
  r = PDF::MM_TO_PT * self
  r.numerator % r.denominator == 0 ? r.to_i : r
end

def PDF.div(a, b)
  r = Rational(a, b)
  r.numerator % r.donominator == 0 ? r.to_i : r
end

class PDF::Point
  def initialize(*arg, **kwarg)
    @x, @y =
      case [arg, kwarg]
      in [PDF::Point], {}
        arg.first.to_a
      in [Numeric, Numeric], {}
        arg
      in [], {x: Numeric, y: Numeric}
        kwarg.values_at(:x, :y)
      end
  end
  attr_reader :x, :y

  def to_a
    [@x, @y]
  end

  def to_h
    {x: @x, y: @y}
  end
end

class PDF::Size
  def initialize(*arg, **kwarg)
    @width, @height =
      case [arg, kwarg]
      in [PDF::Size], {}
        arg.first.to_a
      in [Numeric, Numeric], {}
        arg
      in [], {width: Numeric, height: Numeric}
        kwarg.values_at(:width, :height)
      end
  end
  attr_reader :width, :height

  def to_a
    [@width, @height]
  end

  def to_h
    {width: @width, height: @height}
  end
end

class PDF::Box
  def initialize(*args, **kwarg)
    ltrb = lambda {|left, top, right, bottom|
      [[left, right].min, [top, bottom].max, (right - left).abs, (top - bottom).abs]
    }
    @left, @top, @width, @height =
      case [args, kwarg]
      in [PDF::Box], {}
        args[0].to_a
      in [Numeric, Numeric, Numeric, Numeric], {}
        ltrb.(*args)
      in [PDF::Point, PDF::Size], {}
        [*args[0], *args[1]]
      in [PDF::Size, PDF::Point], {}
        [*args[1], *args[0]]
      in [Numeric, Numeric], {width: Numeric, height: Numeric}
        [args[0], args[1], *kwarg.values_at(:width, :height)]
      in [PDF::Point], {width: Numeric, height: Numeric}
        [*args[0], *kwarg.values_at(:width, :height)]
      in [], {left: Numeric, top: Numeric, width: Numeric, height: Numeric}
        kwarg.values_at(:left, :top, :width, :height)
      in [], {x: Numeric, y: Numeric, width: Numeric, height: Numeric}
        kwarg.values_at(:x, :y, :width, :height)
      in [], {at: [Numeric, Numeric], width: Numeric, height: Numeric}
        [*kwarg[:at], *kwarg.values_at(:width, :height)]
      in [[], {left: Numeric, top: Numeric, right: Numeric, bottom: Numeric}]
        ltrb.(*kwarg.values_at(:left, :top, :right, :bottom))
      end
  end
  attr_reader :left, :top, :width, :height

  def to_a
    [@left, @top, @width, @height]
  end

  def to_h
    {left: @left, top: @top, width: @width, height: @height}
  end

  def size
    PDF::Size.new(@width, @height)
  end

  def left_top
    PDF::Point.new(@left, @top)
  end

  def each_grid(cols: 1, rows: 1)
    return to_enum(__method__, cols:, rows:) { cols * rows } unless block_given?
    width, height = @width / cols, @height / rows
    rows.times.map do |row|
      top = @top + @height * row / rows
      cols.times.map do |col|
        yield PDF::Box.new(left: @left + @width * col / cols, top:, width:, height:)
      end
    end
  end

  def each_horizontal(*widths)
    return to_enum(__method__, *widths) { widths.size } unless block_given?
    case widths.size
    when 0
      return
    when 1
      yield self
    else
      current, total = 0, widths.sum
      left, top, height = @left, @top, @height
      (0...widths.size-1).each do |i|
        current += widths[i]
        right = @left + @width * current.to_f / total
        yield PDF::Box.new(left:, width: right - left, top:, height:)
        left = right
      end
      yield PDF::Box.new(left:, width: @left + @width - left, top:, height:)
    end
  end

  def each_vertical(*heights)
    return to_enum(__method__, *heights) { heights.size } unless block_given?
    case heights.size
    when 0
      return
    when 1
      yield self
    else
      current, total = 0, heights.sum
      left, top, width = @left, @top, @width
      (0...heights.size-1).each do |i|
        current += heights[i]
        bottom = @top - @height * current.to_f / total
        yield PDF::Box.new(left:, width:, top:, height: top - bottom)
        top = bottom
      end
      yield PDF::Box.new(left:, width:, top:, height: top + @height - @top)
    end
  end
end

=end