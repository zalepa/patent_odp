# frozen_string_literal: true

require_relative "patent_odp/version"
require_relative "patent_odp/errors"
require_relative "patent_odp/configuration"

module PatentODP
  class << self
    # Returns the global configuration object
    # @return [Configuration] the configuration instance
    def configuration
      @configuration ||= Configuration.new
    end

    # Yields the configuration object for setup
    # @yield [Configuration] the configuration instance
    # @example
    #   PatentODP.configure do |config|
    #     config.api_key = "your_api_key"
    #   end
    def configure
      yield(configuration)
    end

    # Resets the configuration to a fresh instance
    # Primarily used for testing
    # @return [Configuration] the new configuration instance
    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
