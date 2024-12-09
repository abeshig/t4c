module AlotPDF::Box::Text

  def text(data, *arg, size: nil, align: nil, valign: nil, font: nil)
    arg.each do |v|
      case v
      when Numeric
        raise if size
        size = v
      when String
        raise if font
        font = v
      when :left, :right, :center
        raise if align
        align = v
      when :top, :bottom, :middle
        raise if valign
        valign = v == :middle ? :center : v
      end
    end
    font = self.font if font.nil?
    driver.text(data:, size:, align:, valign:, font:, box: self)
  end

end