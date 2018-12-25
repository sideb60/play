require 'prawn'
require 'barby'
require 'barby/barcode/ean_13'
require 'barby/barcode/code_128'
require 'barby/barcode/code_39'
require 'barby/barcode/qr_code'
require 'barby/outputter/png_outputter'

module Generator
  class PdfGenerator
    include Prawn::View
    include Procto.call

    attr_reader :barcodes, :name, :identifier_type_id, :per_page

    PAGE_MARGINS = {
      7 => 0,
      6 => 9,
      5 => 21,
      4 => 40,
      3 => 70,
      2 => 140
    }

    def initialize(barcodes:, name:, identifier_type_id:, per_page:)
      @barcodes = barcodes
      @name = name
      @per_page = per_page
      @identifier_type_id = identifier_type_id
    end

    def call
      barcodes.each_with_index do |code, idx|
        move_down PAGE_MARGINS[per_page]
        float do
          text "#{name}", size: 20, style: :bold, align: :left
        end
        text "##{idx + 1}", size: 20, align: :right
        move_down 5
        float do
          text "Barcode: #{code[:code]}", size: 15, style: :bold, align: :left
        end
        text "Type Id: #{identifier_type_id}", size: 10, style: :bold, align: :right
        move_down 15

        image barcode_image(code[:barby], code[:encoding]), position: :center
        move_down PAGE_MARGINS[per_page]
        start_new_page if (idx + 1) % per_page == 0 && idx != 0
      end

      filename = "#{Time.now.iso8601}_#{name}".parameterize
      save_as("./result/#{filename}.pdf")
    end

    private

    def barcode_image(barby, encoding)
      StringIO.new(Barby::PngOutputter.new(barby).to_png encoding_options(encoding))
    end

    def document
      @document ||= Prawn::Document.new(page_size: 'A4', top_margin: 30, bottom_margin: 30)
    end

    def encoding_options(encoding)
      {
        ean13: { xdim: 2, height: 50, margin: 2 },
        code128: { xdim: 2, height: 50, margin: 2 },
        code39: { xdim: 2, height: 50, margin: 2 },
        qrcode: { xdim: 2, margin: 2, height: 40 },
      }[encoding]
    end
  end
end
