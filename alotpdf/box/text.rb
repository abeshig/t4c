module AlotPDF::Box::Text
  module TextHelper

  end

  def text(data, size: fontsize.to_i, align: :center, valign: :center)
    driver.text(data:, size:, align:, valign:,
      left: left, top: top, width: width, height: height,
      font: font,
      )
  end
end