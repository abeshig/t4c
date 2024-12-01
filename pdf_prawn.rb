require 'prawn'

class PdfBuilder
  
  def initialize
    @pdf = Prawn::Document.new(skip_page_creation: true)
  end

  def start_new_page()
    @pdf.start_new_page
  end

end