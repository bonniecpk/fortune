namespace :invest do
  task :transfer do
    investments = Fortune::Investment.where(status: "in-progress")

    investments.each do |investment|
      engine    = Fortune::Analysis::CurrencyEx.new(investment)
      engine.transfer_investment if engine.interest_mature?
    end
  end
end
