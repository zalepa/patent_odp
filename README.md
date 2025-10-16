# PatentODP

A Ruby gem for interacting with the USPTO's Open Data Portal (ODP) API. This gem provides a clean, idiomatic Ruby interface to access patent file wrapper data including application metadata, documents, and more.

[![Tests](https://img.shields.io/badge/tests-passing-brightgreen)]()
[![Coverage](https://img.shields.io/badge/coverage-98%25-brightgreen)]()
[![Ruby Version](https://img.shields.io/badge/ruby-%3E%3D%203.2.0-blue)]()
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
  - [Working with Applications](#working-with-applications)
  - [Error Handling](#error-handling)
  - [Advanced Configuration](#advanced-configuration)
- [Security](#security)
- [Development](#development)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

## Features

### Currently Implemented ✅

- **Application Metadata Retrieval** - Fetch detailed patent application information by application number
- **Clean Ruby API** - Idiomatic Ruby interface with snake_case methods and automatic date parsing
- **Comprehensive Error Handling** - Specific error classes for different failure modes
- **Input Validation** - Protection against path traversal and injection attacks
- **Automatic Retries** - Built-in retry logic for transient failures (configurable)
- **Type Safety** - Robust validation of all inputs
- **Well Tested** - 72+ test cases with 98%+ code coverage

### Planned Features 🚧

See [ROADMAP.md](ROADMAP.md) for upcoming features including:
- Search API support
- Document retrieval
- Transaction history
- Assignment data
- Pagination support
- Bulk operations

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'patent_odp'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install patent_odp
```

## Configuration

### Getting an API Key

You'll need a USPTO API key to use this gem. Get one for free at:
[https://data.uspto.gov/apis/getting-started](https://data.uspto.gov/apis/getting-started)

### Basic Configuration

Configure the gem with your API key:

```ruby
require 'patent_odp'

PatentODP.configure do |config|
  config.api_key = 'your_api_key_here'
end
```

### Using Environment Variables

For security, store your API key in an environment variable:

```ruby
# In your .env or environment
# USPTO_API_KEY=your_api_key_here

PatentODP.configure do |config|
  config.api_key = ENV['USPTO_API_KEY']
end
```

## Usage

### Basic Usage

```ruby
require 'patent_odp'

# Configure the gem
PatentODP.configure do |config|
  config.api_key = ENV['USPTO_API_KEY']
end

# Create a client
client = PatentODP::Client.new

# Fetch application data
app = client.application("16123456")

# Access application data
puts app.title
# => "LEARNING ASSISTANCE DEVICE, METHOD OF OPERATING LEARNING ASSISTANCE DEVICE..."

puts app.patent_number
# => "10902286"

puts app.status
# => "Patented Case"
```

### Working with Applications

The `Application` object provides clean, Ruby-friendly access to patent data:

```ruby
app = client.application("16123456")

# Basic Information
app.id                        # => "16123456"
app.title                     # => "Patent title"
app.patent_number             # => "10902286"

# Dates (automatically parsed as Date objects)
app.filing_date               # => #<Date: 2018-09-06>
app.status_date               # => #<Date: 2021-01-06>
app.early_publication_date    # => #<Date: 2019-03-28>

# Status Information
app.status                    # => "Patented Case"
app.patented?                 # => true (boolean helper)

# Publication Information
app.early_publication_number  # => "US20190095759A1"

# People (returns Arrays)
app.inventors                 # => ["Shoji KANADA"]
app.applicants                # => ["FUJIFILM Corporation"]

# Raw data access
app.to_h                      # => Full hash from API
app.inspect                   # => Human-readable representation
```

### Error Handling

The gem provides specific error classes for different failure modes:

```ruby
begin
  app = client.application("invalid")
rescue PatentODP::NotFoundError
  puts "Application not found"
rescue PatentODP::UnauthorizedError
  puts "Invalid API key"
rescue PatentODP::RateLimitError
  puts "Rate limit exceeded - try again later"
rescue PatentODP::ServerError => e
  puts "Server error: #{e.message}"
rescue PatentODP::APIError => e
  puts "API error: #{e.message}"
rescue ArgumentError => e
  puts "Invalid input: #{e.message}"
end
```

#### Error Types

- `PatentODP::ConfigurationError` - Invalid or missing configuration
- `PatentODP::UnauthorizedError` - Invalid API key (401)
- `PatentODP::NotFoundError` - Application not found (404)
- `PatentODP::RateLimitError` - Rate limit exceeded (429)
- `PatentODP::ServerError` - Server errors (5xx)
- `PatentODP::APIError` - Base class for all API errors
- `ArgumentError` - Invalid input (e.g., malformed application number)

### Advanced Configuration

#### Custom Timeouts

```ruby
PatentODP.configure do |config|
  config.api_key = ENV['USPTO_API_KEY']
  config.timeout = 60  # seconds (default: 30)
end
```

#### Disabling Retries

By default, the client retries failed requests (429, 5xx errors). You can disable this:

```ruby
# Globally
PatentODP.configure do |config|
  config.api_key = ENV['USPTO_API_KEY']
  config.retry_enabled = false
end

# Per-client
client = PatentODP::Client.new(retry_enabled: false)
```

#### Per-Client Configuration

Override global settings for specific clients:

```ruby
# Use global config for most things, but custom timeout for this client
client = PatentODP::Client.new(timeout: 120)

# Or completely custom client
client = PatentODP::Client.new(
  api_key: 'different_key',
  timeout: 90,
  retry_enabled: false
)
```

### Rails Integration

In a Rails application, configure in an initializer:

```ruby
# config/initializers/patent_odp.rb
PatentODP.configure do |config|
  config.api_key = Rails.application.credentials.dig(:uspto, :api_key)
  config.timeout = 30
end
```

Then use in your models or controllers:

```ruby
class Patent < ApplicationRecord
  def fetch_metadata
    client = PatentODP::Client.new
    app = client.application(self.application_number)

    update!(
      title: app.title,
      patent_number: app.patent_number,
      filing_date: app.filing_date,
      status: app.status
    )
  rescue PatentODP::NotFoundError
    Rails.logger.warn("Application #{application_number} not found")
  end
end
```

## Security

This gem implements several security best practices:

- ✅ **Input Validation** - All application numbers are validated to prevent path traversal and injection attacks
- ✅ **HTTPS Only** - All API requests use HTTPS
- ✅ **No Secret Logging** - API keys are never logged or exposed in error messages
- ✅ **Type Safety** - All inputs are validated for correct types
- ✅ **Error Sanitization** - Error messages don't expose internal implementation details
- ✅ **Dependency Security** - Uses well-maintained libraries (Faraday)

### Best Practices

1. **Never commit API keys** - Use environment variables or Rails credentials
2. **Validate application numbers** - Before passing user input to the API
3. **Handle rate limits** - Implement backoff strategies in production
4. **Monitor errors** - Track API errors in your application monitoring

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then:

```bash
# Run tests
rake spec

# Run linter
rake rubocop

# Auto-fix linting issues (safe corrections only)
rake rubocop:autocorrect

# Auto-fix all linting issues (including unsafe corrections)
rake rubocop:autocorrect_all

# Run both tests and linter (default)
rake

# View coverage report (automatically generated)
open coverage/index.html
```

### Running Tests

The test suite includes:
- Unit tests for all components
- Integration tests with mocked API responses
- Security tests for input validation
- Error handling tests

```bash
# All tests
rake spec

# Specific file
rspec spec/patent_odp/client_spec.rb

# Specific test
rspec spec/patent_odp/client_spec.rb:30
```

### Interactive Console

You can also run `bin/console` for an interactive prompt that will allow you to experiment:

```bash
bin/console

# In the console:
PatentODP.configure { |c| c.api_key = "your_key" }
client = PatentODP::Client.new
app = client.application("16123456")
```

## Roadmap

See [ROADMAP.md](ROADMAP.md) for planned features and enhancements.

## API Documentation

The USPTO Open Data Portal provides access to:

- **100+ data attributes** for patent applications
- **Daily data refreshes** from USPTO systems
- **Historical data** back to 2001
- **File wrapper documents** including office actions, responses, and more

For complete API documentation, visit:
- [USPTO Open Data Portal](https://data.uspto.gov/)
- [API Documentation](https://data.uspto.gov/apis/patent-file-wrapper/search)
- [Getting Started Guide](https://data.uspto.gov/apis/getting-started)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zalepa/patent_odp. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/zalepa/patent_odp/blob/main/CODE_OF_CONDUCT.md).

### Development Guidelines

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Ensure all tests pass (`rake spec`)
5. Ensure code style compliance (`rubocop`)
6. Commit your changes (`git commit -am 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Create a Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PatentODP project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/zalepa/patent_odp/blob/main/CODE_OF_CONDUCT.md).

## Acknowledgments

- [USPTO Open Data Portal](https://data.uspto.gov/) for providing the API
- Built with [Faraday](https://github.com/lostisland/faraday) for HTTP requests

## Support

- 📚 [Documentation](https://github.com/zalepa/patent_odp)
- 🐛 [Issue Tracker](https://github.com/zalepa/patent_odp/issues)
- 💬 [Discussions](https://github.com/zalepa/patent_odp/discussions)
