AlotPDF::Stroke = Struct.new(:line_width, :line_style, :color) do
  def initialize(*arg, **kw)
    case arg
    in [AlotPDF::Stroke]
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