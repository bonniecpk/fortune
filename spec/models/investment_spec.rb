require_relative '../spec_helper'

describe Fortune::Investment do
  let(:investment) { create(:investment) }

  context "#immature_interest?" do
    it "No interest" do
      expect(investment.immature_interest?).to be(false)
    end

    it "No" do
      investment.interest = build(:interest, mature_length: 1, start: Date.today - 1.month)
      expect(investment.immature_interest?).to be(false)
    end

    it "Yes" do
      investment.interest = build(:interest, mature_length: 12)
      expect(investment.immature_interest?).to be(true)
    end
  end

  context "interest doesn't exist" do
    it "#actual_converted_interest" do
      expect(investment.actual_converted_interest).to be(0)
    end

    it "#current_converted_interest" do
      expect(investment.actual_converted_interest).to be(0)
    end

    it "#annual_maturity" do
      expect(investment.annual_maturity).to be(0)
    end
  end

end
