# frozen_string_literal: true

RSpec.describe PatentODP do
  it "has a version number" do
    expect(PatentODP::VERSION).not_to be_nil
  end

  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(described_class.configuration).to be_a(PatentODP::Configuration)
    end

    it "returns the same instance each time (singleton)" do
      config1 = described_class.configuration
      config2 = described_class.configuration
      expect(config1).to be(config2)
    end
  end

  describe ".configure" do
    after do
      # Reset configuration after each test
      described_class.reset_configuration!
    end

    it "yields the configuration object" do
      described_class.configure do |config|
        expect(config).to be_a(PatentODP::Configuration)
      end
    end

    it "allows setting the api_key" do
      described_class.configure do |config|
        config.api_key = "test_key"
      end
      expect(described_class.configuration.api_key).to eq("test_key")
    end

    it "allows setting multiple configuration options" do
      described_class.configure do |config|
        config.api_key = "my_key"
        config.timeout = 60
      end

      expect(described_class.configuration.api_key).to eq("my_key")
      expect(described_class.configuration.timeout).to eq(60)
      expect(described_class.configuration.base_url).to eq("https://api.uspto.gov/api/v1/patent/applications")
    end
  end

  describe ".reset_configuration!" do
    it "creates a new configuration instance" do
      described_class.configure { |c| c.api_key = "old_key" }
      old_config = described_class.configuration

      described_class.reset_configuration!
      new_config = described_class.configuration

      expect(new_config).not_to be(old_config)
      expect(new_config.api_key).to be_nil
    end
  end
end
