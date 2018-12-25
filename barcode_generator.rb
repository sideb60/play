require 'ean13'
require 'securerandom'
require 'base32/crockford'
require 'barby'
require 'barby/barcode/ean_13'
require 'barby/barcode/code_128'
require 'barby/barcode/code_39'
require 'barby/barcode/qr_code'

module Generator
  class BarcodeGenerator
    include Procto.call
    attr_reader :quantity, :encoding, :length, :start, :prefix, :sequential

    CODE39CHARS = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-$%./+".freeze

    def initialize(options)
      @quantity = options.quantity
      @encoding = options.encoding
      @length = options.barcode_length
      @sequential = options.sequential
      @start = options.start || 0
      @prefix = options.prefix || ''
    end

    def call
      (start..(quantity + start)).map do |index|
        barcode = if sequential
                    generate_sequence(index)
                  else
                    send "generate_#{encoding}"
                  end
        {
          code: barcode,
          barby: barby_barcode(barcode),
          encoding: encoding
        }
      end
    end

    private

    def generate_sequence(number)
      padding = length - prefix.size
      "#{prefix}" + "#{number}".rjust(padding, '0')
    end

    def generate_ean13
      data = SecureRandom.random_number(123)
      modulo_data = data.modulo(99_999_999).to_s
      random_padding = (12 - data.to_s.size).times.map { SecureRandom.random_number(10) }
      modulo_data += random_padding.join
      EAN13.complete(modulo_data)
    end

    def generate_code128
      bits = length * 5
      random = SecureRandom.random_number(2**bits)
      Base32::Crockford.encode(random, length: length).downcase
    end

    def generate_code39
      (0..length).map { CODE39CHARS[rand(CODE39CHARS.size)] }.join
    end

    def generate_qrcode
      generate_code128
    end

    def barby_barcode(barcode)
      BarbyEncode.call(encoding: encoding, barcode: barcode)
    end
  end
end
