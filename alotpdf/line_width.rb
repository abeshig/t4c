AlotPDF::LineWidth = Struct.new(:line_width) do
  def initialize(*arg, **kw)
    case arg
    in [AlotPDF::LineWidth]
      super(*arg[0].to_a)
    in [Array]
      super(*arg[0])
    in [Hash]
      super(**arg[0])
    else
      super(*arg, **kw)
    end
  end

  def to_i
    line_width.to_i
  end
  alias to_int to_i
end