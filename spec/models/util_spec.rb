require_relative '../spec_helper'

describe Fortune::Util do
  class Dummy
    include Mongoid::Document
    extend  Fortune::Util

    field :name,  type: String
    field :price, type: Integer
  end

  FactoryGirl.define do
    factory :dummy do
      sequence(:name)  { |n| "Dummy Name #{n}" }
      sequence(:price) { |n| n + 10 }
    end
  end

  describe "#round_time" do
    let(:exact_hour) { DateTime.parse("2014-10-14T13:00:00") }

    it "param is nil" do
      expect { Dummy.round_time(nil) }.to raise_error(Fortune::Util::ParseError)
    end

    it "exact hour" do
      expect(Dummy.round_time(exact_hour)).to eq(exact_hour)
    end

    it "round down" do
      time = DateTime.parse("2014-10-14T13:29:00")
      expect(Dummy.round_time(time)).to eq(exact_hour)
    end

    it "round up" do
      time = DateTime.parse("2014-10-14T12:30:00")
      expect(Dummy.round_time(time)).to eq(exact_hour)
    end
  end

  describe "#max_obj" do
    it "empty collection" do
      expect(Dummy.max_obj(:price)).to be_nil
    end

    it "one collection" do
      dummy  = FactoryGirl.create(:dummy)
      result = Dummy.max_obj(:price)

      expect(result.name).to eq(dummy.name)
      expect(result.price).to eq(dummy.price)
    end

    it "multiple collections" do
      dummies = []
      5.times { dummies << FactoryGirl.create(:dummy) }

      result = Dummy.max_obj(:price)

      expect(result.name).to eq(dummies.last.name)
      expect(result.price).to eq(dummies.last.price)
    end
  end

  describe "#min_obj" do
    it "empty collection" do
      expect(Dummy.min_obj(:price)).to be_nil
    end
    
    it "one collection" do
      dummy  = FactoryGirl.create(:dummy)
      result = Dummy.min_obj(:price)

      expect(result.name).to eq(dummy.name)
      expect(result.price).to eq(dummy.price)
    end
    
    it "multiple collections" do
      dummies = []
      5.times { dummies << FactoryGirl.create(:dummy) }

      result = Dummy.min_obj(:price)

      expect(result.name).to eq(dummies.first.name)
      expect(result.price).to eq(dummies.first.price)
    end
  end
end
