# frozen_string_literal: true

module PatentODP
  # Configuration class for PatentODP gem
  # Handles API key, base URL, and other configurable options
  class Configuration
    attr_accessor :api_key, :retry_enabled
    attr_reader :base_url, :timeout

    def initialize(api_key: nil, timeout: nil, retry_enabled: nil)
      @api_key = api_key
      @base_url = "https://api.uspto.gov/api/v1/patent/applications"
      self.timeout = timeout || 30
      @retry_enabled = retry_enabled.nil? || retry_enabled
    end

    # Set timeout with validation
    # @param value [Integer] Timeout in seconds
    # @raise [ArgumentError] if timeout is invalid
    def timeout=(value)
      raise ArgumentError, "Timeout must be a positive number" if value && (!value.is_a?(Numeric) || value <= 0)

      @timeout = value
    end

    # Returns the API key if set, raises an error otherwise
    # @return [String] the API key
    # @raise [ConfigurationError] if API key is not set or is blank
    def api_key!
      if @api_key.nil? || !@api_key.is_a?(String) || @api_key.strip.empty?
        raise ConfigurationError,
              "API key is required. Set it with PatentODP.configure { |c| c.api_key = 'your_key' }"
      end
      @api_key
    end
  end
end
