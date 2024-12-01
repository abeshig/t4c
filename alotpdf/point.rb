AlotPDF::Point = Struct.new(:x, :y) do
  def initialize(*arg, **kw)
    case arg
    in [AlotPDF::Point]
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
    "#{x},#{y}"
  end
end