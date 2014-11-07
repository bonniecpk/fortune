FactoryGirl.define do
  factory :bank_interest, class: Fortune::BankInterest do |i|
    i.currency { "BRL" }
    i.rate     { rand(0..0.8) }
    i.maturity { rand(3..24) }
  end
end
