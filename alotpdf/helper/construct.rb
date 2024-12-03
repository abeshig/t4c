module AlotPDF::Helper::Construct

  def self.implicit_construct(constructor, arg)
    case arg
    when Array
      constructor.(*arg)
    when Hash
      constructor.(**arg)
    else
      constructor.(arg)
    end
  end

  def self.Point(*arg, **kw)
    AlotPDF::Point.new(*
      if kw.empty?
        case arg
        in [AlotPDF::Point]
          arg.first.to_a
        in [Numeric, Numeric]
          arg
        end
      else
        raise ArgumentError unless arg.empty?
        case kw
        in {x: Numeric, y: Numeric}
          kw.values_at(:x, :y)
        end
      end
    )
  end
  def Point(*, **)
    AlotPDF::Helper::Construct.Point(*, **)
  end

  def self.Size(*arg, **kw)
    AlotPDF::Size.new(*
      if kw.empty?
        case arg
        in [AlotPDF::Size]
          arg.first.to_a
        in [Numeric, Numeric]
          arg
        end
      else
        raise ArgumentError unless arg.empty?
        case kw
        in {width: Numeric, height: Numeric}
          kw.values_at(:width, :height)
        end
      end
    )
  end
  def Size(*, **)
    AlotPDF::Helper::Construct.Size(*, **)
  end

  def self.Stroke(*arg, **kw)
    data = {}
    set_data = lambda {|key, value|
      if value
        raise ArgumentError if data.has_key?(key)
        data[key] = value
      end
    }
    arg.each do |a|
      case a
      when AlotPDF::Stroke
        set_data.(:line_width, a.line_width)
        set_data.(:line_style, a.line_style)
        set_data.(:color, a.color)
      when Numeric
        set_data.(:line_width, AlotPDF::LineWidth.new(a))
      when Symbol, String
        a = a.to_sym
        if AlotPDF::LineStyle::Builtin.has_key?(a)
          set_data.(:line_style, AlotPDF::LineStyle::Builtin[a])
        elsif AlotPDF::Color::Builtin.has_key?(a)
          set_data.(:color, AlotPDF::Color::Builtin[a])
        else
          rgb = ColorHelper.parse_rgb(a)
          if rgb
            set_data.(:color, AlotPDF::Color.new(*rgb))
          else
            raise ArgumentError
          end
        end
      when AlotPDF::LineWidth
        set_data.(:line_width, a)
      when AlotPDF::LineStyle
        set_data.(:line_style, a)
      when AlotPDF::Color
        set_data.(:color, a)
      end
    end
    set_data.(:line_width, kw[:line_width])
    set_data.(:line_style, kw[:line_style])
    set_data.(:color, kw[:color])
    AlotPDF::Stroke.new(**data)
  end
  def Stroke(*, **)
    AlotPDF::Helper::Construct.Stroke(*, **)
  end

  def self.LineWidth(*arg, **kw)
    AlotPDF::LineWidth.new(*
      if kw.empty?
        case arg
        in [AlotPDF::LineWidth]
          arg.first.to_a
        in [Numeric]
          arg
        end
      else
        raise ArgumentError unless arg.empty?
        case kw
        in {line_width: Numeric}
          kw.values_at(:line_width)
        in {width: Numeric}
          kw.values_at(:width)
        end
      end
    )
  end
  def LineWidth(*, **)
    AlotPDF::Helper::Construct.LineWidth(*, **)
  end

  def self.LineStyle(*arg, **kw)
    st = AlotPDF::LineStyle.new(*
      if kw.empty?
        case arg
        in [AlotPDF::LineStyle]
          arg.first.to_a
        in [Symbol | String]
          arg = AlotPDF::LineStyle::Builtin[arg.first.to_sym]
          raise ArgumentError if arg.nil?
          arg.to_a
        end
      else
        raise ArgumentError unless arg.empty? && (kw.keys - AlotPDF::LineStyle.members).empty?
        ({cap: :butt, join: :miter}.merge(kw)).values_at(*AlotPDF::LineStyle.members)
      end
    )
    raise ArgumentError unless st.valid_cap? && st.valid_join?
    return st
  end
  def LineStyle(*, **)
    AlotPDF::Helper::Construct.LineStyle(*, **)
  end

  module ColorHelper
    def self.parse_rgb(str)
      str = str[1..] if str.start_with?('#')
      case str.size
      when 3
        [str[0], str[1], str[2]].map { Integer(_1, 16) * 17 }
      when 6
        [str[0..1], str[2..3], str[4..5]].map { Integer(_1, 16) }
      else
        nil
      end
    end
  end

  def self.Color(*arg, **kw)
    AlotPDF::Color.new(*
      if kw.empty?
        case arg
        in [AlotPDF::Color]
          arg.first.to_a
        in [Symbol | String]
          s = arg.first
          color = AlotPDF::Color::Builtin[s.to_sym]
          if color
            color.to_a
          else
            ColorHelper.parse_rgb(s) || raise(ArgumentError)
          end
        in [Numeric, Numeric, Numeric]
          arg.map(&:to_i)
        end
      else
        raise ArgumentError unless arg.empty?
        case kw
        in {red: Numeric, green: Numeric, blue: Numeric}
          kw.values_at(:red, :green, :blue).map(&:to_i)
        in {r: Numeric, g: Numeric, b: Numeric}
          kw.values_at(:r, :g, :b).map(&:to_i)
        end
      end
    )
  end
  def Color(*, **)
    AlotPDF::Helper::Construct.Color(*, **)
  end

  def self.Bounds(*arg, **kw)
    names = AlotPDF::Bounds.members
    arg.map! {
      case _1
      when /^true$/i
        true
      when /^false$/i
        false
      when String
        _1.to_sym
      else
        _1
      end
    }
    AlotPDF::Bounds.new(*
      if kw.empty?
        raise ArgumentError if arg.empty?
        case arg
        in [AlotPDF::Bounds]
          arg.first.to_a
        in [true|false]
          arg * names.size
        in [true|false, true|false]
          [arg[1], arg[0], arg[1], arg[0]]
        in [true|false, true|false, true|false, true|false]
          arg
        else
          raise ArgumentError unless (arg - names).empty?
          arg &= names
          names.map {|name| arg.include?(name) }
        end
      else
        raise ArgumentError unless arg.empty? && (kw.keys - names).empty?
        names.map {|name| kw[name] ? true : false }
      end
    )
  end
  def Bounds(*, **)
    AlotPDF::Helper::Construct.Bounds(*, **)
  end
end