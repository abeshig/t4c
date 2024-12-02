module AlotPDF::Box::Margin
  using AlotPDF

  def margin(*arg, left: nil, top: nil, right: nil, bottom: nil)
    arg = case arg
      in []
        raise ArgumentError if left.nil? and top.nil? and right.nil? and bottom.nil?
        [0, 0, 0, 0]
      in [Numeric]
        [arg[0], arg[0], arg[0], arg[0]]
      in [Numeric, Numeric]
        [arg[1], arg[0], arg[1], arg[0]]
      in [Numeric, Numeric, Numeric, Numeric]
        arg
      end
    left ||= arg[0]
    top ||= arg[1]
    right ||= arg[2]
    bottom ||= arg[3]
    width, height = self.width, self.height
    left *= width if left.rate?
    right *= width if right.rate?
    top *= height if top.rate?
    bottom *= height if bottom.rate?
    AlotPDF::Box.new(self, driver,
      self.left + left,
      self.top - top,
      width - left - right,
      height - top - bottom,
    )
  end

end