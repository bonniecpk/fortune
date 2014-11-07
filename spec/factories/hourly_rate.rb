FactoryGirl.define do
  factory :hourly_rate, class: Fortune::HourlyRate do |r|
    r.currency { "BRL" }
    r.price    { rand(2.0..120) }
  end
end
