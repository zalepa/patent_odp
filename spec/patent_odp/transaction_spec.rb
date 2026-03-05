# frozen_string_literal: true

RSpec.describe PatentODP::Transaction do
  let(:transaction_data) do
    {
      "eventCode" => "CTNF",
      "eventDescriptionText" => "Non-Final Rejection mailed",
      "eventDate" => "2024-06-15"
    }
  end

  subject(:transaction) { described_class.new(transaction_data) }

  describe "#event_code" do
    it "returns the event code" do
      expect(transaction.event_code).to eq("CTNF")
    end
  end

  describe "#description" do
    it "returns the description" do
      expect(transaction.description).to eq("Non-Final Rejection mailed")
    end
  end

  describe "#event_date" do
    it "returns a Date object" do
      expect(transaction.event_date).to eq(Date.new(2024, 6, 15))
    end

    it "returns nil for missing date" do
      txn = described_class.new({})
      expect(txn.event_date).to be_nil
    end
  end

  describe "#inspect" do
    it "returns a readable representation" do
      expect(transaction.inspect).to include("CTNF")
      expect(transaction.inspect).to include("Non-Final Rejection mailed")
    end
  end
end
