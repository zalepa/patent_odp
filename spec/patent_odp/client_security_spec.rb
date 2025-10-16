# frozen_string_literal: true

RSpec.describe PatentODP::Client do
  let(:api_key) { "test_api_key_123" }
  let(:client) { described_class.new(api_key: api_key) }

  describe "security validations" do
    describe "#application input validation" do
      it "rejects nil application numbers" do
        expect { client.application(nil) }.to raise_error(ArgumentError, /cannot be nil/)
      end

      it "rejects non-string application numbers" do
        expect { client.application(12345) }.to raise_error(ArgumentError, /must be a string/)
      end

      it "rejects empty application numbers" do
        expect { client.application("") }.to raise_error(ArgumentError, /cannot be empty/)
        expect { client.application("   ") }.to raise_error(ArgumentError, /cannot be empty/)
      end

      it "rejects path traversal attempts with ../" do
        expect { client.application("../../../etc/passwd") }.to raise_error(
          ArgumentError,
          /contains invalid characters/
        )
      end

      it "rejects path traversal attempts with .." do
        expect { client.application("..") }.to raise_error(ArgumentError, /contains invalid characters/)
      end

      it "rejects application numbers with slashes" do
        expect { client.application("16123456/admin") }.to raise_error(
          ArgumentError,
          /contains invalid characters/
        )
      end

      it "rejects application numbers with special characters" do
        expect { client.application("16123456;rm -rf /") }.to raise_error(
          ArgumentError,
          /contains invalid characters/
        )
      end

      it "rejects application numbers with null bytes" do
        expect { client.application("16123456\x00") }.to raise_error(
          ArgumentError,
          /contains invalid characters/
        )
      end

      it "accepts valid alphanumeric application numbers" do
        stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/16123456")
          .to_return(
            status: 200,
            body: { "patentFileWrapperDataBag" => [{ "applicationMetaData" => {} }] }.to_json
          )

        expect { client.application("16123456") }.not_to raise_error
      end

      it "accepts application numbers with hyphens" do
        stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/16-123456")
          .to_return(
            status: 200,
            body: { "patentFileWrapperDataBag" => [{ "applicationMetaData" => {} }] }.to_json
          )

        expect { client.application("16-123456") }.not_to raise_error
      end

      it "accepts application numbers with underscores" do
        stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/16_123456")
          .to_return(
            status: 200,
            body: { "patentFileWrapperDataBag" => [{ "applicationMetaData" => {} }] }.to_json
          )

        expect { client.application("16_123456") }.not_to raise_error
      end
    end

    describe "JSON parsing error handling" do
      it "raises APIError when response is not valid JSON" do
        stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/16123456")
          .to_return(status: 200, body: "not json at all")

        expect { client.application("16123456") }.to raise_error(
          PatentODP::APIError,
          /Failed to parse API response/
        )
      end

      it "raises APIError when response is truncated JSON" do
        stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/16123456")
          .to_return(status: 200, body: '{"incomplete": ')

        expect { client.application("16123456") }.to raise_error(
          PatentODP::APIError,
          /Failed to parse API response/
        )
      end
    end
  end
end
