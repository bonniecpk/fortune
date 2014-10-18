require_relative '../spec_helper'

describe Fortune::DailyRate do
  it { should validate_uniqueness_of(:currency).scoped_to(:date) }
end
