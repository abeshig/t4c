module AlotPDF::Box::Split
  module Helper
    using AlotPDF

    def self.split_size(values, size, gap)
      return [] if values.size == 0
      values = values.dup
      size -= gap * (values.size - 1)
      values.map! {|n| n.rate? ? size * n : n }
      zero_count = values.count(0)
      if zero_count > 0
        remain = size - values.sum
        if zero_count == 1
          values[values.index(0)] = remain
        else
          remain /= zero_count
          values.map! {|n| n == 0 ? remain : n }
        end
      end
      return values
    end
  end

  def vertical_split(*heights, gap: 0)
    heights = Helper.split_size(heights, height, gap)
    top = self.top
    heights.map do |height, n|
      box = AlotPDF::Box.new(self, driver, left, top, width, height)
      top -= height + gap
      box
    end
  end

  def horizontal_split(*widths, gap: 0)
    widths = Helper.split_size(widths, width, gap)
    left = self.left
    widths.map do |width, n|
      box = AlotPDF::Box.new(self, driver, left, top, width, height)
      left += width + gap
      box
    end
  end

end