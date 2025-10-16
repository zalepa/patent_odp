# frozen_string_literal: true

RSpec.describe PatentODP::Configuration do
  describe "#api_key" do
    it "defaults to nil" do
      config = described_class.new
      expect(config.api_key).to be_nil
    end

    it "can be set" do
      config = described_class.new
      config.api_key = "test_key_123"
      expect(config.api_key).to eq("test_key_123")
    end

    it "can be set via constructor" do
      config = described_class.new(api_key: "test_key_456")
      expect(config.api_key).to eq("test_key_456")
    end
  end

  describe "#api_key!" do
    it "returns the api_key if set" do
      config = described_class.new(api_key: "valid_key")
      expect(config.api_key!).to eq("valid_key")
    end

    it "raises an error if api_key is nil" do
      config = described_class.new
      expect { config.api_key! }.to raise_error(
        PatentODP::ConfigurationError,
        "API key is required. Set it with PatentODP.configure { |c| c.api_key = 'your_key' }"
      )
    end

    it "raises an error if api_key is empty string" do
      config = described_class.new(api_key: "")
      expect { config.api_key! }.to raise_error(
        PatentODP::ConfigurationError,
        "API key is required. Set it with PatentODP.configure { |c| c.api_key = 'your_key' }"
      )
    end

    it "raises an error if api_key is only whitespace" do
      config = described_class.new(api_key: "   ")
      expect { config.api_key! }.to raise_error(
        PatentODP::ConfigurationError,
        "API key is required. Set it with PatentODP.configure { |c| c.api_key = 'your_key' }"
      )
    end
  end

  describe "#base_url" do
    it "has a default USPTO API base URL" do
      config = described_class.new
      expect(config.base_url).to eq("https://api.uspto.gov/api/v1/patent/applications")
    end

    it "cannot be overridden" do
      config = described_class.new
      expect do
        config.base_url = "https://custom.api.url"
      end.to raise_error(NoMethodError)
      expect(config.base_url).to eq("https://api.uspto.gov/api/v1/patent/applications")
    end
  end

  describe "#timeout" do
    it "defaults to 30 seconds" do
      config = described_class.new
      expect(config.timeout).to eq(30)
    end

    it "can be customized" do
      config = described_class.new
      config.timeout = 60
      expect(config.timeout).to eq(60)
    end
  end
end
