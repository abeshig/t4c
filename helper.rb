
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