module AlotPDF::Box::Stroke
  module StrokeHelper
    def self.getLTRB(*arg, **kw)
      return [true, true, true, true] if arg.empty? && kw.empty?
      for v in arg
        v = v.to_sym
        kw[v] = true if [:left, :top, :right, :bottom].include?(v)
      end
      kw.values_at(:left, :top, :right, :bottom)
    end

    def self.getStroke(*arg, **kw)
      for v in arg
        kw[:stroke] = v if AlotPDF::Stroke === v
      end
      case kw
      in {stroke: AlotPDF::Stroke}
        kw[:stroke]
      else
        nil
      end
    end
  end

  def stroke_bounds(*arg, **kw)
    ltrb = StrokeHelper.getLTRB(*arg, **kw)
    stroke = StrokeHelper.getStroke(*arg, **kw) || AlotPDF::Stroke.new(self.stroke)
    driver.stroke_bounds(self, ltrb, stroke)
  end
end