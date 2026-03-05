# frozen_string_literal: true

require "date"

module PatentODP
  # Represents a transaction event from a patent application's history
  class Transaction
    # @return [Hash] Raw transaction data from API
    attr_reader :data

    # @param data [Hash] Raw transaction data from API response
    def initialize(data)
      @data = data
    end

    # @return [String, nil] Transaction event code
    def event_code
      @data["eventCode"]
    end

    # @return [String, nil] Human-readable description of the event
    def description
      @data["eventDescriptionText"]
    end

    # @return [Date, nil] Date of the event
    def event_date
      parse_date(@data["eventDate"])
    end

    # @return [String] Human-readable representation
    def inspect
      "#<PatentODP::Transaction code=#{event_code.inspect} description=#{description.inspect}>"
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
