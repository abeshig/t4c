module AlotPDF::Box::Stroke
  def stroke_bounds(*arg, bounds: nil, stroke: nil)
    helper = AlotPDF::Helper::Construct
    arg_bounds = arg & AlotPDF::Bounds.members
    arg -= AlotPDF::Bounds.members
    raise ArgumentError if !arg_bounds.empty? && bounds || !arg.empty? && stroke
    if bounds
      bounds = helper.implicit_construct(helper.singleton_method(:Bounds), bounds)
    else
      bounds = arg_bounds.empty? ? helper.Bounds(true) : helper.Bounds(*arg_bounds)
    end
    if stroke
      stroke = helper.implicit_construct(helper.singleton_method(:Stroke), stroke)
    else
      stroke = arg.empty? ? self.stroke : helper.Stroke(*arg)
    end
    driver.stroke_bounds(self, bounds, stroke)
  end
end