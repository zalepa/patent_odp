# frozen_string_literal: true

module PatentODP
  # Base error class for all PatentODP errors
  class Error < StandardError; end

  # Raised when configuration is invalid or missing
  class ConfigurationError < Error; end

  # Raised when API request fails
  class APIError < Error; end

  # Raised when API returns 4xx error
  class ClientError < APIError; end

  # Raised when API returns 5xx error
  class ServerError < APIError; end

  # Raised when API returns 401 Unauthorized
  class UnauthorizedError < ClientError; end

  # Raised when API returns 404 Not Found
  class NotFoundError < ClientError; end

  # Raised when API returns 429 Too Many Requests
  class RateLimitError < ClientError; end
end
