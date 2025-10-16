# PatentOdp

A Ruby gem for interacting with the USPTO's Open Data Portal (ODP) API. This gem provides a simple interface to access patent file wrapper data including applications, documents, and search functionality.

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

You'll need a USPTO API key to use this gem. Get one at [https://data.uspto.gov/apis/getting-started](https://data.uspto.gov/apis/getting-started).

```ruby
PatentOdp.configure do |config|
  config.api_key = 'your_api_key_here'
end
```

## Usage

Coming soon - examples will be added as the API wrapper is developed.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/george-zalepa/patent_odp. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/george-zalepa/patent_odp/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PatentOdp project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/george-zalepa/patent_odp/blob/main/CODE_OF_CONDUCT.md).
