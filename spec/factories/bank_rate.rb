FactoryGirl.define do
  factory :bank_rate, class: Fortune::BankRate do |i|
    i.base_currency { "USD" }
    i.to_currency   { "BRL" }
  end
end
