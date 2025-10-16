# frozen_string_literal: true

require "date"

module PatentODP
  # Represents a patent application with metadata from the USPTO API
  class Application
    # @return [Hash] Raw application data from API
    attr_reader :data

    # @param data [Hash] Raw application data from API response
    # @param application_number [String, nil] Application number from request
    def initialize(data, application_number = nil)
      @data = data
      @metadata = data["applicationMetaData"] || {}
      @application_number = application_number
    end

    # @return [String, nil] Application ID
    def id
      @application_number
    end

    # @return [String, nil] Patent number if granted
    def patent_number
      @metadata["patentNumber"]
    end

    # @return [String, nil] Patent/Application title
    def title
      @metadata["inventionTitle"]
    end

    # @return [Date, nil] Filing date
    def filing_date
      parse_date(@metadata["filingDate"])
    end

    # @return [String, nil] Application status
    def status
      @metadata["applicationStatusDescriptionText"]
    end

    # @return [Date, nil] Status date
    def status_date
      parse_date(@metadata["applicationStatusDate"])
    end

    # @return [String, nil] Early publication number
    def early_publication_number
      @metadata["earliestPublicationNumber"]
    end

    # @return [Date, nil] Early publication date
    def early_publication_date
      parse_date(@metadata["earliestPublicationDate"])
    end

    # @return [Array<String>] List of applicant names
    def applicants
      extract_names(@metadata["applicantBag"], "applicantNameText")
    end

    # @return [Array<String>] List of inventor names
    def inventors
      extract_names(@metadata["inventorBag"], "inventorNameText")
    end

    # @return [Boolean] Whether the application has been granted
    def patented?
      status&.include?("Patented") || false
    end

    # @return [Hash] Raw data hash
    def to_h
      @data
    end

    # @return [String] Human-readable representation
    def inspect
      "#<PatentODP::Application id=#{id.inspect} title=#{title.inspect}>"
    end

    private

    # Parse date string to Date object
    # @param date_string [String, nil]
    # @return [Date, nil]
    def parse_date(date_string)
      return nil if date_string.nil? || date_string.empty?

      Date.parse(date_string)
    rescue ArgumentError
      nil
    end

    # Extract names from nested API structure
    # @param items [Array, nil] Array of items with name fields
    # @param name_field [String] Name of the field containing names
    # @return [Array<String>]
    def extract_names(items, name_field)
      return [] if items.nil?

      Array(items).map { |item| item[name_field] }.compact
    end
  end
end
