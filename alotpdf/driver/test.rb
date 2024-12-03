class AlotPDF::Driver::Test
  using AlotPDF

  class LogEntry < Hash
    def initialize(**data)
      self.replace(data)
      @timestamp = Time.now
    end

    attr_reader :timestamp
  end

  def initialize(width: 210.mm, height: 297.mm)
    @width, @height = width, height
    @log = {}
  end

  def eject_log
    ejected = @log
    @log = {}
    return ejected
  end

  def register_log(key, **data)
    @log[key] = @log[key].to_a + [LogEntry.new(**data)]
  end

  def save_as(filename)
    register_log __method__, filename:
  end

  def page_box()
    AlotPDF::Box.new(nil, self, 0.mm, @height, @width, @height)
  end

  def new_page()
    register_log __method__
    page_box
  end

  def stroke_bounds(box, bounds, stroke)
    register_log __method__, box:, bounds:, stroke:
  end

end