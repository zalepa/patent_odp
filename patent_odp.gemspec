# frozen_string_literal: true

require_relative "lib/patent_odp/version"

Gem::Specification.new do |spec|
  spec.name = "patent_odp"
  spec.version = PatentODP::VERSION
  spec.authors = ["George Zalepa"]
  spec.email = ["george.zalepa@gmail.com"]

  spec.summary = "Ruby wrapper for the USPTO Open Data Portal (ODP) API"
  spec.description = "A Ruby gem for interacting with the USPTO's Open Data Portal API, " \
                     "providing access to patent file wrapper data."
  spec.homepage = "https://github.com/zalepa/patent_odp"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/zalepa/patent_odp"
  spec.metadata["changelog_uri"] = "https://github.com/zalepa/patent_odp/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-retry", "~> 2.0"
end
