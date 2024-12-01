module AlotPDF

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

require_relative 'point.rb'
require_relative 'size.rb'
require_relative 'line_width.rb'
require_relative 'line_style.rb'
require_relative 'color.rb'
require_relative 'stroke.rb'
require_relative 'box.rb'
require_relative 'helper.rb'

module AlotPDF::Driver
end