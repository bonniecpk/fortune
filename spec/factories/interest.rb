FactoryGirl.define do
  factory :interest, class: Fortune::Interest do |i|
    i.rate          { rand(0..0.12) }
    i.mature_length { rand(3..24) }
    i.start         { Date.today }
  end
end
