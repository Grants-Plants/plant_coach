require 'rails_helper'

RSpec.describe SeedDefaultData, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:plant_type) }
    it { should validate_presence_of(:days_to_maturity) }
    it { should validate_presence_of(:seed_days_to_transplant) }
    it { should validate_presence_of(:days_relative_to_frost_date) }
  end

  describe 'relationships' do

  end

end