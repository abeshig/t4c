module AlotPDF::Box::Margin
  using AlotPDF

  module MarginHelper
    def self.getLTRB(*arg, **kw)
      case [arg, kw]
      in [Numeric], {}
        [arg[0], arg[0], arg[0], arg[0]] 
      in [Numeric, Numeric], {}
        [arg[1], arg[0], arg[1], arg[0]]
      in [Numeric, Numeric, Numeric, Numeric], {}
        arg
      in [], {**}
        kw = {left: 0, top: 0, right: 0, bottom: 0}.merge(kw)
        case kw
        in {left: Numeric, top: Numeric, right: Numeric, bottom: Numeric}
          kw.values_at(:left, :top, :right, :bottom)
        end
      end
    end
  end

  def margin(*, **)
    w, h = width, height
    l, t, r, b = MarginHelper.getLTRB(*, **)
    l *= w if l.rate?
    r *= w if r.rate?
    t *= h if t.rate?
    b *= h if b.rate?
    AlotPDF::Box.new(self, driver, left+l, top-t, w-l-r, h-t-b)
  end

end