require 'csv'

module Generator
  class CsvGenerator
    include Procto.call

    attr_reader :barcodes, :name, :identifier_type_id
    def initialize(barcodes:, name:, identifier_type_id:)
      @barcodes = barcodes
      @name = name
      @identifier_type_id = identifier_type_id
    end

    def call
      filename = "#{Time.now.iso8601}_#{name}".parameterize
      CSV.open("./result/#{filename}.csv", 'w') do |csv|
        csv << %w(ticket_number ticket_type_id ticket_type_name status)
        barcodes.each do |barcode|
          csv << [barcode[:code], identifier_type_id, name, 'ok']
        end
      end
    end
  end
end
