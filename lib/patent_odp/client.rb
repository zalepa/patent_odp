# frozen_string_literal: true

require "faraday"
require "faraday/retry"
require "json"

module PatentODP
  # HTTP client for interacting with the USPTO Open Data Portal API
  class Client
    BASE_URL = "https://api.uspto.gov/api/v1/patent/applications"

    # @param api_key [String, nil] API key for authentication. If nil, uses global config.
    # @param timeout [Integer, nil] Request timeout in seconds. If nil, uses global config.
    # @param retry_enabled [Boolean, nil] Enable retry logic. If nil, uses global config.
    def initialize(api_key: nil, timeout: nil, retry_enabled: nil)
      @api_key = api_key || PatentODP.configuration.api_key!
      @timeout = timeout || PatentODP.configuration.timeout
      @retry_enabled = retry_enabled.nil? ? PatentODP.configuration.retry_enabled : retry_enabled
      @connection = build_connection
    end

    # Fetch application metadata by application number
    # @param application_number [String] The patent application number
    # @return [Application] Application object with metadata
    # @raise [NotFoundError] if application doesn't exist
    # @raise [UnauthorizedError] if API key is invalid
    # @raise [RateLimitError] if rate limit is exceeded
    # @raise [ServerError] for server errors
    def application(application_number)
      response = @connection.get(application_number) do |req|
        req.headers["X-API-KEY"] = @api_key
      end

      handle_response(response, application_number)
    end

    private

    def build_connection
      Faraday.new(url: BASE_URL) do |conn|
        if @retry_enabled
          conn.request :retry, {
            max: 3,
            interval: 0.5,
            backoff_factor: 2,
            retry_statuses: [429, 500, 502, 503, 504]
          }
        end
        conn.adapter Faraday.default_adapter
        conn.options.timeout = @timeout
        conn.options.open_timeout = 10
      end
    end

    def handle_response(response, application_number)
      case response.status
      when 200
        parse_application_response(response, application_number)
      when 401
        raise UnauthorizedError, "Invalid API key"
      when 404
        raise NotFoundError, "Application not found"
      when 429
        raise RateLimitError, "API rate limit exceeded"
      when 500..599
        raise ServerError, "Server error: #{response.status}"
      else
        raise APIError, "Unexpected response: #{response.status}"
      end
    end

    def parse_application_response(response, application_number)
      data = JSON.parse(response.body)

      # Navigate the nested structure to get application data
      wrapper_bag = data["patentFileWrapperDataBag"]
      return Application.new({}, application_number) if wrapper_bag.nil? || wrapper_bag.empty?

      # Get the first (and should be only) item in the bag
      wrapper_data = wrapper_bag.first
      return Application.new({}, application_number) unless wrapper_data

      # Extract the application metadata
      app_metadata = wrapper_data["applicationMetaData"]
      return Application.new({}, application_number) unless app_metadata

      # Pass the full wrapper data so Application can access events, etc if needed
      Application.new(wrapper_data, application_number)
    end
  end
end
