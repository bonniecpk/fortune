require_relative '../spec_helper'

describe Fortune::Investment do
  context "#immature_interest?" do
    before(:each) do
      @investment = create(:investment)
    end

    it "No interest" do
      expect(@investment.immature_interest?).to be(false)
    end

    it "No" do
      @investment.interest = build(:interest, mature_length: 1, start: Date.today - 1.month)
      expect(@investment.immature_interest?).to be(false)
    end

    it "Yes" do
      @investment.interest = build(:interest, mature_length: 12)
      expect(@investment.immature_interest?).to be(true)
    end
  end
end
