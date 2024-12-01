module AlotPDF::Box::Stroke
  module StrokeHelper
    def self.getLTRB(*arg, **kw)
      return [true, true, true, true] if arg.empty? && kw.empty?
      ltrb = [false, false, false, false]
      for v in arg
        v = v.to_s
        kw[v.to_sym] = true if ["left", "top", "right", "bottom"].include?(v)
      end
      unless kw.empty?
        ltrb[0] = true if kw[:left]
        ltrb[1] = true if kw[:top]
        ltrb[2] = true if kw[:right]
        ltrb[3] = true if kw[:bottom]
      end
      return ltrb
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
    stroke = StrokeHelper.getStroke(*arg, **kw) || AlotPDF::Stroke.new(stroke)
    driver.stroke_bounds(self, ltrb, stroke)
  end
end