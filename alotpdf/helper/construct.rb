module AlotPDF::Helper::Construct

  module BoxHelper
    def self.convertLTRBtoLTWH(left, top, right, bottom)
      [[left, right].min, [top, bottom].max, (right - left).abs, (top - bottom).abs]
    end

    def self.getLTWH(*arg, **kw)
      case [arg, kw]
      in [AlotPDF::Box], {}
        arg.first.to_a
      in [Numeric, Numeric, Numeric, Numeric], {}
        arg
      in [Numeric, Numeric], {width: Numeric, height: Numeric}
        [arg[0], arg[1], *kw.values_at(:width, :height)]
      in [], {left: Numeric, top: Numeric, right: Numeric, bottom: Numeric}
        convertLTRBtoLTWH(*kw.values_at(:left, :top, :right, :bottom))
      end
    end
  end

  def Box(*arg, **kw)
    raise "dont use this"
  end

  module PointHelper
    def self.getXY(*arg, **kw)
      case [arg, kw]
      in [AlotPDF::Point], {}
        arg.first.to_a
      in [Numeric, Numeric], {}
        arg
      in [], {x: Numeric, y: Numeric}
        kw.values_at(:x, :y)
      end
    end
  end

  def Point(*, **)
    AlotPDF::Point.new(*PointHelper.getXY(*, **))
  end

  module SizeHelper
    def self.getWH(*arg, **kw)
      case [arg, kw]
      in [AlotPDF::Size], {}
        arg.first.to_a
      in [Numeric, Numeric], {}
        arg
      in [], {width: Numeric, height: Numeric}
        kw.values_at(:width, :height)
      end
    end
  end

  def Size(*, **)
    AlotPDF::Size.new(*SizeHelper.getWH(*, **))
  end

  module StrokeHelper
    extend AlotPDF::Helper::Construct
    def self.parse(*arg, **kw)
      case [arg, kw]
      in [nil|AlotPDF::LineWidth, nil|AlotPDF::LineStyle, nil|AlotPDF::Color], {}
        arg
      end
    end
  end

  def Stroke(*, **)
    AlotPDF::Stroke.new(*StrokeHelper.parse(*, **))
  end

  module LineWidthHelper
    def self.parse(*arg, **kw)
      case [arg, kw]
      in [AlotPDF::LineWidth], {}
        arg.first.to_a
      in [Numeric], {}
        arg
      in [], {line_width: Numeric}
        kw.values_at(:line_width)
      in [], {width: Numeric}
        kw.values_at(:width)
      end
    end
  end

  def LineWidth(*, **)
    AlotPDF::LineWidth.new(*LineWidthHelper.parse(*, **))
  end

  module LineStyleHelper
    def self.parse(*arg, **kw)
      case [arg, kw]
      in [AlotPDF::LineStyle], {}
        arg.first.to_a
      else
        case format(*arg, **kw)
        in ["solid", *]
          [nil, nil, nil]
        else
          arg[1..-1]
        end
      end
    end
    def self.format(*arg, **kw)
      if kw.empty?
        case arg
        in []
          ["solid"]
        in [Symbol]
          [arg[0].to_s]
        end
      else
        kw = {style: kw[:line_style], dash: nil, space: nil, phase: nil}.merge(kw)
        case [arg, kw]
        in [], {style: nil|Symbol, dash: nil|Numeric, space: nil|Numeric, phase: nil|Numeric}
          [kw[:style].to_s, *kw.values_at(:dash, :space, :phase)]
        end
      end
    end
  end

  def LineStyle(*, **)
    AlotPDF::LineStyle.new(*LineStyleHelper.parse(*, **))
  end

  module ColorHelper
    def self.parse(*arg, **kw)
      case [arg, kw]
      in [AlotPDF::Color], {}
        arg.first.to_a
      in [String], {}
        s = arg[0]
        s = s[1..-1] if s.start_with?('#')
        [s[0..1], s[2..3], s[4..5]].map { Integer(_1, 16) }
      in [Numeric, Numeric, Numeric], {}
        arg.map { _1.to_i }
      in [], {red: Numeric, green: Numeric, blue: Numeric}
        kw.values_at(:red, :green, :blue).map { _1.to_i }
      in [], {r: Numeric, g: Numeric, b: Numeric}
        kw.values_at(:r, :g, :b).map { _1.to_i }
      end
    end
  end

  def Color(*, **)
    AlotPDF::Color.new(*ColorHelper.parse(*, **))
  end
end