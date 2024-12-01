# - :cap
#   - :butt (default)
#   - :round
#   - :projecting_square
# - :join
#   - :miter (default)
#   - :round
#   - :bevel
AlotPDF::LineStyle = Struct.new(:dash, :space, :phase, :cap, :join) do
  def initialize(*arg, **kw)
    case arg
    in [AlotPDF::LineStyle]
      super(*arg[0].to_a)
    in [Array]
      super(*arg[0])
    in [Hash]
      super(**arg[0])
    else
      super(*arg, **kw)
    end
  end
end