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
      # Disable retries for faster test execution
      client_no_retry = described_class.new(api_key: api_key, retry_enabled: false)

      stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/16123456")
        .with(headers: { "X-API-KEY" => api_key })
        .to_return(status: 429, body: { "error" => "Rate limit exceeded" }.to_json)

      expect { client_no_retry.application("16123456") }.to raise_error(PatentODP::RateLimitError)
    end

    it "raises ServerError for 5xx errors" do
      # Disable retries for faster test execution
      client_no_retry = described_class.new(api_key: api_key, retry_enabled: false)

      stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/16123456")
        .with(headers: { "X-API-KEY" => api_key })
        .to_return(status: 500, body: { "error" => "Internal server error" }.to_json)

      expect { client_no_retry.application("16123456") }.to raise_error(PatentODP::ServerError)
    end
  end

  describe "#documents" do
    let(:application_number) { "16123456" }
    let(:mock_documents_response) do
      {
        "documentBag" => [
          {
            "applicationNumberText" => "16123456",
            "officialDate" => "2024-06-15",
            "documentIdentifier" => "DOC-001",
            "documentCode" => "CTNF",
            "documentCodeDescriptionText" => "Non-Final Rejection",
            "directionCategory" => "Outgoing",
            "downloadOptionBag" => [
              {
                "mimeTypeIdentifier" => "PDF",
                "downloadUrl" => "https://api.uspto.gov/download/001",
                "pageTotalQuantity" => 12
              }
            ]
          },
          {
            "applicationNumberText" => "16123456",
            "officialDate" => "2024-03-01",
            "documentIdentifier" => "DOC-002",
            "documentCode" => "SPEC",
            "documentCodeDescriptionText" => "Specification",
            "directionCategory" => "Incoming",
            "downloadOptionBag" => [
              {
                "mimeTypeIdentifier" => "PDF",
                "downloadUrl" => "https://api.uspto.gov/download/002",
                "pageTotalQuantity" => 25
              }
            ]
          }
        ]
      }
    end

    it "returns an array of Document objects" do
      stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/16123456/documents")
        .with(headers: { "X-API-KEY" => api_key })
        .to_return(status: 200, body: mock_documents_response.to_json, headers: { "Content-Type" => "application/json" })

      docs = client.documents(application_number)
      expect(docs).to be_an(Array)
      expect(docs.length).to eq(2)
      expect(docs.first).to be_a(PatentODP::Document)
    end

    it "parses document fields correctly" do
      stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/16123456/documents")
        .with(headers: { "X-API-KEY" => api_key })
        .to_return(status: 200, body: mock_documents_response.to_json, headers: { "Content-Type" => "application/json" })

      doc = client.documents(application_number).first
      expect(doc.document_code).to eq("CTNF")
      expect(doc.description).to eq("Non-Final Rejection")
      expect(doc.official_date).to eq(Date.new(2024, 6, 15))
      expect(doc.outgoing?).to be true
      expect(doc.pdf_download_url).to eq("https://api.uspto.gov/download/001")
    end

    it "returns empty array when no documents" do
      stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/16123456/documents")
        .with(headers: { "X-API-KEY" => api_key })
        .to_return(status: 200, body: { "documentBag" => [] }.to_json, headers: { "Content-Type" => "application/json" })

      expect(client.documents(application_number)).to eq([])
    end

    it "raises NotFoundError for 404" do
      stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/99999999/documents")
        .with(headers: { "X-API-KEY" => api_key })
        .to_return(status: 404, body: { "error" => "Not found" }.to_json)

      expect { client.documents("99999999") }.to raise_error(PatentODP::NotFoundError)
    end

    it "validates application number" do
      expect { client.documents("../etc/passwd") }.to raise_error(ArgumentError)
    end
  end

  describe "#transactions" do
    let(:application_number) { "16123456" }
    let(:mock_transactions_response) do
      {
        "eventDataBag" => [
          {
            "eventCode" => "CTNF",
            "eventDescriptionText" => "Non-Final Rejection mailed",
            "eventDate" => "2024-06-15"
          },
          {
            "eventCode" => "A...",
            "eventDescriptionText" => "Response filed",
            "eventDate" => "2024-09-10"
          }
        ]
      }
    end

    it "returns an array of Transaction objects" do
      stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/16123456/transactions")
        .with(headers: { "X-API-KEY" => api_key })
        .to_return(status: 200, body: mock_transactions_response.to_json, headers: { "Content-Type" => "application/json" })

      txns = client.transactions(application_number)
      expect(txns).to be_an(Array)
      expect(txns.length).to eq(2)
      expect(txns.first).to be_a(PatentODP::Transaction)
    end

    it "parses transaction fields correctly" do
      stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/16123456/transactions")
        .with(headers: { "X-API-KEY" => api_key })
        .to_return(status: 200, body: mock_transactions_response.to_json, headers: { "Content-Type" => "application/json" })

      txn = client.transactions(application_number).first
      expect(txn.event_code).to eq("CTNF")
      expect(txn.description).to eq("Non-Final Rejection mailed")
      expect(txn.event_date).to eq(Date.new(2024, 6, 15))
    end

    it "returns empty array when no transactions" do
      stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/16123456/transactions")
        .with(headers: { "X-API-KEY" => api_key })
        .to_return(status: 200, body: { "eventDataBag" => [] }.to_json, headers: { "Content-Type" => "application/json" })

      expect(client.transactions(application_number)).to eq([])
    end

    it "raises NotFoundError for 404" do
      stub_request(:get, "https://api.uspto.gov/api/v1/patent/applications/99999999/transactions")
        .with(headers: { "X-API-KEY" => api_key })
        .to_return(status: 404, body: { "error" => "Not found" }.to_json)

      expect { client.transactions("99999999") }.to raise_error(PatentODP::NotFoundError)
    end

    it "validates application number" do
      expect { client.transactions("../etc/passwd") }.to raise_error(ArgumentError)
    end
  end
end
