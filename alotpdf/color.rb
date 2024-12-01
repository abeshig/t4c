AlotPDF::Color = Struct.new(:red, :green, :blue) do
  def initialize(*arg, **kw)
    case arg
    in [AlotPDF::Color]
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
    to_a.map { _1.to_i.to_s(16).rjust('0')[-2..-1] }.join('').upcase
  end
end