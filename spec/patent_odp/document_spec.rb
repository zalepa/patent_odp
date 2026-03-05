# frozen_string_literal: true

RSpec.describe PatentODP::Document do
  let(:document_data) do
    {
      "applicationNumberText" => "16123456",
      "officialDate" => "2024-06-15",
      "documentIdentifier" => "DOC-12345",
      "documentCode" => "CTNF",
      "documentCodeDescriptionText" => "Non-Final Rejection",
      "directionCategory" => "Outgoing",
      "downloadOptionBag" => [
        {
          "mimeTypeIdentifier" => "PDF",
          "downloadUrl" => "https://api.uspto.gov/download/12345",
          "pageTotalQuantity" => 12
        }
      ]
    }
  end

  subject(:document) { described_class.new(document_data) }

  describe "#document_identifier" do
    it "returns the document identifier" do
      expect(document.document_identifier).to eq("DOC-12345")
    end
  end

  describe "#document_code" do
    it "returns the document code" do
      expect(document.document_code).to eq("CTNF")
    end
  end

  describe "#description" do
    it "returns the description text" do
      expect(document.description).to eq("Non-Final Rejection")
    end
  end

  describe "#direction" do
    it "returns the direction category" do
      expect(document.direction).to eq("Outgoing")
    end
  end

  describe "#official_date" do
    it "returns a Date object" do
      expect(document.official_date).to eq(Date.new(2024, 6, 15))
    end

    it "returns nil for missing date" do
      doc = described_class.new({})
      expect(doc.official_date).to be_nil
    end
  end

  describe "#application_number" do
    it "returns the application number" do
      expect(document.application_number).to eq("16123456")
    end
  end

  describe "#download_options" do
    it "returns formatted download options" do
      options = document.download_options
      expect(options.length).to eq(1)
      expect(options.first[:mime_type]).to eq("PDF")
      expect(options.first[:download_url]).to eq("https://api.uspto.gov/download/12345")
      expect(options.first[:page_count]).to eq(12)
    end

    it "returns empty array when no options" do
      doc = described_class.new({})
      expect(doc.download_options).to eq([])
    end
  end

  describe "#pdf_download_url" do
    it "returns the PDF download URL" do
      expect(document.pdf_download_url).to eq("https://api.uspto.gov/download/12345")
    end
  end

  describe "#page_count" do
    it "returns the page count" do
      expect(document.page_count).to eq(12)
    end
  end

  describe "#incoming?" do
    it "returns false for outgoing documents" do
      expect(document.incoming?).to be false
    end

    it "returns true for incoming documents" do
      doc = described_class.new("directionCategory" => "Incoming")
      expect(doc.incoming?).to be true
    end
  end

  describe "#outgoing?" do
    it "returns true for outgoing documents" do
      expect(document.outgoing?).to be true
    end
  end

  describe "#inspect" do
    it "returns a readable representation" do
      expect(document.inspect).to include("CTNF")
      expect(document.inspect).to include("Non-Final Rejection")
    end
  end
end
