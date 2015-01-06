require_relative '../spec_helper'

describe Fortune::Interest do
  context "#mature?" do
    it "No" do
      expect(build(:interest, mature_length: 12).mature?).to eq(false)
    end

    it "Yes" do
      interest = build(:interest, mature_length: 1, start: Date.today - 2.months)
      expect(interest.mature?).to eq(true)
    end

    it "Mature today" do
      interest = build(:interest, mature_length: 1, start: Date.today - 1.month)
      expect(interest.mature?).to eq(true)
    end
  end

  context "#actual_amount" do
    let(:investment) { create(:investment) }

    it "amount exists" do
      interest = build(:interest, amount: 300)
      investment.interest = interest
      expect(interest.actual_amount).to be(interest.amount)
    end

    it "amount doesn't exist" do
      interest = build(:interest)
      investment.interest = interest
      expect(interest.actual_amount).to be(investment.capital * (1 + interest.rate / interest.annual_maturity))
    end
  end
end
