# frozen_string_literal: true

RSpec.describe PatentODP::Application do
  let(:sample_data) do
    {
      "applicationMetaData" => {
        "patentNumber" => "11234567",
        "inventionTitle" => "Method and System for Testing",
        "filingDate" => "2020-01-15",
        "applicationStatusDescriptionText" => "Patented Case",
        "applicationStatusDate" => "2022-03-20",
        "earliestPublicationNumber" => "US20210123456A1",
        "earliestPublicationDate" => "2021-04-22",
        "applicantBag" => [
          { "applicantNameText" => "Test Corporation" }
        ],
        "inventorBag" => [
          { "inventorNameText" => "John Doe" },
          { "inventorNameText" => "Jane Smith" }
        ]
      }
    }
  end

  let(:application) { described_class.new(sample_data, "16123456") }

  describe "#initialize" do
    it "creates an application from API response data" do
      expect(application).to be_a(PatentODP::Application)
    end
  end

  describe "attribute accessors" do
    it "provides access to id (applId)" do
      expect(application.id).to eq("16123456")
    end

    it "provides access to patent_number" do
      expect(application.patent_number).to eq("11234567")
    end

    it "provides access to title" do
      expect(application.title).to eq("Method and System for Testing")
    end

    it "provides access to filing_date" do
      expect(application.filing_date).to eq(Date.parse("2020-01-15"))
    end

    it "provides access to status" do
      expect(application.status).to eq("Patented Case")
    end

    it "provides access to status_date" do
      expect(application.status_date).to eq(Date.parse("2022-03-20"))
    end

    it "provides access to early_publication_number" do
      expect(application.early_publication_number).to eq("US20210123456A1")
    end

    it "provides access to early_publication_date" do
      expect(application.early_publication_date).to eq(Date.parse("2021-04-22"))
    end
  end

  describe "#applicants" do
    it "returns an array of applicant names" do
      expect(application.applicants).to eq(["Test Corporation"])
    end

    it "handles missing applicantBag" do
      app = described_class.new({}, "16123456")
      expect(app.applicants).to eq([])
    end

    it "handles empty applicant array" do
      data = sample_data.dup
      data["applicationMetaData"]["applicantBag"] = []
      app = described_class.new(data, "16123456")
      expect(app.applicants).to eq([])
    end
  end

  describe "#inventors" do
    it "returns an array of inventor names" do
      expect(application.inventors).to eq(["John Doe", "Jane Smith"])
    end

    it "handles missing inventorBag" do
      app = described_class.new({}, "16123456")
      expect(app.inventors).to eq([])
    end

    it "handles single inventor" do
      data = sample_data.dup
      data["applicationMetaData"]["inventorBag"] = [{ "inventorNameText" => "Solo Inventor" }]
      app = described_class.new(data, "16123456")
      expect(app.inventors).to eq(["Solo Inventor"])
    end
  end

  describe "#patented?" do
    it "returns true when status contains 'Patented'" do
      expect(application.patented?).to be true
    end

    it "returns false when status does not contain 'Patented'" do
      data = sample_data.dup
      data["applicationMetaData"]["applicationStatusDescriptionText"] = "Pending"
      app = described_class.new(data, "16123456")
      expect(app.patented?).to be false
    end

    it "returns false when status is missing" do
      app = described_class.new({}, "16123456")
      expect(app.patented?).to be false
    end
  end

  describe "#to_h" do
    it "returns the raw data hash" do
      expect(application.to_h).to eq(sample_data)
    end
  end

  describe "#inspect" do
    it "provides a readable string representation" do
      output = application.inspect
      expect(output).to include("PatentODP::Application")
      expect(output).to include("16123456")
      expect(output).to include("Method and System for Testing")
    end
  end
end
