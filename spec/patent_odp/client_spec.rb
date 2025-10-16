# frozen_string_literal: true

RSpec.describe PatentODP::Client do
  let(:api_key) { "test_api_key_123" }
  let(:client) { described_class.new(api_key: api_key) }

  describe "#initialize" do
    it "accepts an api_key parameter" do
      client = described_class.new(api_key: "custom_key")
      expect(client.instance_variable_get(:@api_key)).to eq("custom_key")
    end

    it "uses the global configuration if no api_key provided" do
      PatentODP.configure { |c| c.api_key = "global_key" }
      client = described_class.new
      expect(client.instance_variable_get(:@api_key)).to eq("global_key")
    ensure
      PatentODP.reset_configuration!
    end

    it "raises ConfigurationError if no api_key is available" do
      PatentODP.reset_configuration!
      expect { described_class.new }.to raise_error(
        PatentODP::ConfigurationError,
        /API key is required/
      )
    end
  end

  describe "#application" do
    let(:application_number) { "16123456" }
    let(:mock_response_body) do
      {
        "count" => 1,
        "patentFileWrapperDataBag" => [{
          "applicationMetaData" => {
            "patentNumber" => "11234567",
            "inventionTitle" => "Method and System for Testing",
            "filingDate" => "2020-01-15",
            "applicationStatusDescriptionText" => "Patented Case",
            "applicationStatusDate" => "2022-03-20",
            "earliestPublicationNumber" => "US20210123456A1",
            "earliestPublicationDate" => "2021-04-22",
            "applicantBag" => [{
              "applicantNameText" => "Test Corporation"
            }],
            "inventorBag" => [{
              "inventorNameText" => "John Doe"
            }]
          }
        }]
      }
    end

    it "returns an Application object" do
      stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/16123456")
        .with(headers: { "X-API-KEY" => api_key })
        .to_return(status: 200, body: mock_response_body.to_json, headers: { "Content-Type" => "application/json" })

      app = client.application(application_number)
      expect(app).to be_a(PatentODP::Application)
    end

    it "passes the application number correctly" do
      stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/16123456")
        .with(headers: { "X-API-KEY" => api_key })
        .to_return(status: 200, body: mock_response_body.to_json, headers: { "Content-Type" => "application/json" })

      app = client.application("16123456")
      expect(app.id).to eq("16123456")
    end

    it "handles application numbers with leading zeros" do
      stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/01234567")
        .with(headers: { "X-API-KEY" => api_key })
        .to_return(status: 200, body: mock_response_body.to_json, headers: { "Content-Type" => "application/json" })

      expect { client.application("01234567") }.not_to raise_error
    end

    it "raises NotFoundError when application doesn't exist" do
      stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/99999999")
        .with(headers: { "X-API-KEY" => api_key })
        .to_return(status: 404, body: { "error" => "Not found" }.to_json)

      expect { client.application("99999999") }.to raise_error(PatentODP::NotFoundError)
    end

    it "raises UnauthorizedError with invalid API key" do
      stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/16123456")
        .with(headers: { "X-API-KEY" => api_key })
        .to_return(status: 401, body: { "error" => "Unauthorized" }.to_json)

      expect { client.application("16123456") }.to raise_error(PatentODP::UnauthorizedError)
    end

    it "raises RateLimitError when rate limited" do
      stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/16123456")
        .with(headers: { "X-API-KEY" => api_key })
        .to_return(status: 429, body: { "error" => "Rate limit exceeded" }.to_json)

      expect { client.application("16123456") }.to raise_error(PatentODP::RateLimitError)
    end

    it "raises ServerError for 5xx errors" do
      stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/16123456")
        .with(headers: { "X-API-KEY" => api_key })
        .to_return(status: 500, body: { "error" => "Internal server error" }.to_json)

      expect { client.application("16123456") }.to raise_error(PatentODP::ServerError)
    end
  end
end
