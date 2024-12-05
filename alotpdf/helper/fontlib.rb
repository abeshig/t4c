module AlotPDF::Helper::FontLibrary
  module_function
  include File::Constants

  def detect_fonts(dir)
    return {} unless File.directory?(dir)
    data = Dir.glob("**/*.ttf", FNM_CASEFOLD, base: dir).map {|file|
      path = File.join(dir, file)
      [File.basename(path, File.extname(path)), path]
    }
    dup = data.map(&:first).tally.to_a.detect { _1.last > 1 }&.first
    raise "found a duplicated font name: #{dup}" if dup
    data.to_h
  end

end