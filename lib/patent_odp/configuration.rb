# frozen_string_literal: true

module PatentODP
  # Configuration class for PatentODP gem
  # Handles API key, base URL, and other configurable options
  class Configuration
    attr_accessor :api_key, :timeout, :retry_enabled
    attr_reader :base_url

    def initialize(api_key: nil, timeout: nil, retry_enabled: nil)
      @api_key = api_key
      @base_url = "https://api.uspto.gov/api/v1/patent/applications"
      @timeout = timeout || 30
      @retry_enabled = retry_enabled.nil? ? true : retry_enabled
    end

    # Returns the API key if set, raises an error otherwise
    # @return [String] the API key
    # @raise [ConfigurationError] if API key is not set or is blank
    def api_key!
      if @api_key.nil? || @api_key.strip.empty?
        raise ConfigurationError,
              "API key is required. Set it with PatentODP.configure { |c| c.api_key = 'your_key' }"
      end
      @api_key
    end
  end
end
