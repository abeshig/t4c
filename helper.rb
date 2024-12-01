
class NaturalNumber
  class Error < StandardError
  end
end

def NaturalNumber.parse(str)
  Integer(str, 10).tap do |i|
    if i <= 0
      raise NaturalNumber::Error.new('invalid number')
    end
  end
end

module RationalCalc
  refine Integer do
    def /(other)
      case other
      when Integer
        self % other == 0 ? super(other) : Rational(self, other)
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
      r = Rational(254 * self, 720)
      r.numerator % r.denominator == 0 ? r.to_i : r
    end
  end
end