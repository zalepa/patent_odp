# frozen_string_literal: true

require "date"

module PatentODP
  # Represents a document from a patent application's file wrapper
  class Document
    # @return [Hash] Raw document data from API
    attr_reader :data

    # @param data [Hash] Raw document data from API response
    def initialize(data)
      @data = data
    end

    # @return [String, nil] Unique document identifier
    def document_identifier
      @data["documentIdentifier"]
    end

    # @return [String, nil] Document code (e.g., "CTNF", "NOA")
    def document_code
      @data["documentCode"]
    end

    # @return [String, nil] Human-readable description of the document code
    def description
      @data["documentCodeDescriptionText"]
    end

    # @return [String, nil] Direction category ("Incoming" or "Outgoing")
    def direction
      @data["directionCategory"]
    end

    # @return [Date, nil] Official date of the document
    def official_date
      parse_date(@data["officialDate"])
    end

    # @return [String, nil] Application number this document belongs to
    def application_number
      @data["applicationNumberText"]
    end

    # @return [Array<Hash>] Download options with mime_type, url, and page_count
    def download_options
      Array(@data["downloadOptionBag"]).map do |opt|
        {
          mime_type: opt["mimeTypeIdentifier"],
          download_url: opt["downloadUrl"],
          page_count: opt["pageTotalQuantity"]
        }
      end
    end

    # @return [String, nil] URL for the PDF download (most common format)
    def pdf_download_url
      pdf_option = download_options.find { |opt| opt[:mime_type]&.upcase&.include?("PDF") }
      pdf_option&.dig(:download_url) || download_options.first&.dig(:download_url)
    end

    # @return [Integer, nil] Total page count
    def page_count
      download_options.first&.dig(:page_count)
    end

    # @return [Boolean] Whether this is an incoming document (from applicant)
    def incoming?
      direction&.downcase == "incoming"
    end

    # @return [Boolean] Whether this is an outgoing document (from USPTO)
    def outgoing?
      direction&.downcase == "outgoing"
    end

    # @return [String] Human-readable representation
    def inspect
      "#<PatentODP::Document code=#{document_code.inspect} description=#{description.inspect}>"
    end

    private

    def parse_date(date_string)
      return nil if date_string.nil? || date_string.to_s.empty?

      Date.parse(date_string.to_s)
    rescue ArgumentError
      nil
    end
  end
end
