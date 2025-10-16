# frozen_string_literal: true

RSpec.describe PatentODP::Configuration do
  describe "security validations" do
    describe "#api_key!" do
      it "rejects non-string API keys" do
        config = described_class.new(api_key: 12_345)
        expect { config.api_key! }.to raise_error(
          PatentODP::ConfigurationError,
          /API key is required/
        )
      end

      it "rejects array API keys" do
        config = described_class.new(api_key: ["key"])
        expect { config.api_key! }.to raise_error(
          PatentODP::ConfigurationError,
          /API key is required/
        )
      end

      it "rejects hash API keys" do
        config = described_class.new(api_key: { key: "value" })
        expect { config.api_key! }.to raise_error(
          PatentODP::ConfigurationError,
          /API key is required/
        )
      end
    end

    describe "#timeout=" do
      it "rejects negative timeout values" do
        config = described_class.new
        expect { config.timeout = -10 }.to raise_error(ArgumentError, /must be a positive number/)
      end

      it "rejects zero timeout values" do
        config = described_class.new
        expect { config.timeout = 0 }.to raise_error(ArgumentError, /must be a positive number/)
      end

      it "rejects non-numeric timeout values" do
        config = described_class.new
        expect { config.timeout = "30" }.to raise_error(ArgumentError, /must be a positive number/)
      end

      it "accepts positive integer timeout values" do
        config = described_class.new
        expect { config.timeout = 60 }.not_to raise_error
        expect(config.timeout).to eq(60)
      end

      it "accepts positive float timeout values" do
        config = described_class.new
        expect { config.timeout = 30.5 }.not_to raise_error
        expect(config.timeout).to eq(30.5)
      end
    end
  end
end
