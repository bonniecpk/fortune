require_relative '../spec_helper'

describe Fortune::HourlyRate do
  it { should validate_uniqueness_of(:currency).scoped_to(:datetime) }
end
