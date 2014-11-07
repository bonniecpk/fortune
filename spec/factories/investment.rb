FactoryGirl.define do
  factory :investment, class: Fortune::Investment do |i|
    i.capital       { rand(20000) }
    i.base_currency { "USD" }
    i.buy_currency  { "BRL" }
    i.buy_price     { rand(2.0..120) }
    i.buy_date      { Date.today - rand(60).days }
    i.target_rate   { rand(0..0.1) }
    i.loss_rate     { rand(0..0.1) }
    i.sold          { false }
  end
end
