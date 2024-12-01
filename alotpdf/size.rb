AlotPDF::Size = Struct.new(:width, :height) do
  def initialize(*arg, **kw)
    case arg
    in [AlotPDF::Size]
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
    "#{width}x#{height}"
  end
end