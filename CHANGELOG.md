# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Search API support
- Document retrieval
- Transaction history
- Assignment data
- Pagination support

See [ROADMAP.md](ROADMAP.md) for detailed future plans.

## [0.1.0] - 2024-10-16

### Added

#### Core Features
- Application metadata retrieval by application number via `Client#application`
- `PatentODP::Client` class for HTTP communication with USPTO API
- `PatentODP::Application` class representing patent application data with clean Ruby API
- Global configuration via `PatentODP.configure`
- Per-client configuration override support

#### Application Data Access
- `Application#id` - Application number
- `Application#title` - Patent/application title
- `Application#patent_number` - Patent number if granted
- `Application#filing_date` - Filing date (Date object)
- `Application#status` - Application status
- `Application#status_date` - Status date (Date object)
- `Application#early_publication_number` - Publication number
- `Application#early_publication_date` - Publication date (Date object)
- `Application#inventors` - Array of inventor names
- `Application#applicants` - Array of applicant names
- `Application#patented?` - Boolean helper for patent status
- `Application#to_h` - Access raw API response data
- `Application#inspect` - Human-readable string representation

#### Configuration Options
- `api_key` - USPTO API key (required)
- `timeout` - HTTP request timeout in seconds (default: 30)
- `retry_enabled` - Enable/disable automatic retry logic (default: true)
- `base_url` - API base URL (read-only, set to USPTO endpoint)

#### Error Handling
- `PatentODP::Error` - Base error class
- `PatentODP::ConfigurationError` - Configuration validation errors
- `PatentODP::APIError` - Base class for API-related errors
- `PatentODP::ClientError` - 4xx HTTP errors
- `PatentODP::ServerError` - 5xx HTTP errors
- `PatentODP::UnauthorizedError` - 401 authentication errors
- `PatentODP::NotFoundError` - 404 not found errors
- `PatentODP::RateLimitError` - 429 rate limit errors

#### Security Features
- Input validation for application numbers to prevent path traversal attacks
- Character whitelist validation (alphanumeric, underscore, hyphen only)
- Type safety checks for all configuration values
- API key validation before requests
- Timeout value validation (must be positive number)
- Protection against non-string API keys
- Defensive nil checks throughout

#### Developer Experience
- Automatic date parsing (converts strings to Ruby `Date` objects)
- Snake_case method names following Ruby conventions
- Detailed YARD documentation
- Helpful error messages with configuration hints
- Clean, chainable API design

#### HTTP Client Features
- Built on Faraday for reliable HTTP communication
- Automatic retry logic for transient failures (429, 5xx errors)
- Configurable retry behavior (max: 3, with exponential backoff)
- Proper timeout handling (connect and read timeouts)
- HTTPS-only communication
- API key sent via `X-API-KEY` header

#### Testing
- 72 comprehensive test cases
- 98%+ code coverage with SimpleCov
- Unit tests for all components
- Integration tests with mocked API responses
- Security tests for input validation
- Error handling tests
- WebMock integration for reliable HTTP testing
- Fast test suite (< 0.05 seconds)

#### Documentation
- Comprehensive README with usage examples
- Rails integration examples
- Error handling guide
- Security best practices
- ROADMAP documenting planned features
- Inline code documentation with YARD

#### Dependencies
- `faraday` (~> 2.0) - HTTP client
- `faraday-retry` (~> 2.0) - Automatic retry middleware
- Development: `rspec`, `webmock`, `rubocop`, `simplecov`

### Technical Details

#### API Coverage
- `GET /api/v1/patent/applications/{application_number}` - Retrieve application metadata

#### Ruby Version
- Requires Ruby >= 3.2.0
- Tested on Ruby 3.4.x

#### Performance
- Default 30-second timeout
- Configurable connection and read timeouts
- Optional retry logic can be disabled for faster failures in tests

### Security

#### Vulnerability Fixes
- Fixed path traversal vulnerability in application number handling
- Added input validation regex to prevent injection attacks
- Added type checking to prevent NoMethodError on invalid inputs
- Added JSON parsing error handling
- Protected against malformed API responses

#### Best Practices
- HTTPS-only communication
- No secrets logged or exposed in errors
- API keys passed via headers (not URL)
- Comprehensive input validation
- Safe error messages that don't leak internal details

[unreleased]: https://github.com/zalepa/patent_odp/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/zalepa/patent_odp/releases/tag/v0.1.0
