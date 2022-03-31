require 'rails_helper'

RSpec.describe 'User Plants API Endpoint' do
  describe 'POST user plants' do
    it 'creates new plant that the user will be planting' do
      plant = Plant.create!(plant_type: "Tomato", name: "Sungold", days_relative_to_frost_date: 14, days_to_maturity: 54, hybrid_status: 1)
      user = User.create!(name: "Joel User", email: 'joel@123.com', password: "12345", zip_code: 80123)

      post '/api/v1/user_plants', params: { user_id: user.id, plant_id: plant.id}
      result = JSON.parse(response.body, symbolize_names: true)
      new_plant = UserPlant.last

      expect(response).to be_successful
      expect(new_plant.plant_id).to eq(plant.id)
      expect(new_plant.user_id).to eq(user.id)
    end

    it 'will return a json error message if there was a problem' do
      plant = Plant.create!(plant_type: "Tomato", name: "Sungold", days_relative_to_frost_date: 14, days_to_maturity: 54, hybrid_status: 1)
      user = User.create!(name: "Joel User", email: 'joel@123.com', password: "12345", zip_code: 80123)

      post '/api/v1/user_plants', params: { user_id: nil, plant_id: plant.id}
      result = JSON.parse(response.body, symbolize_names: true)

      expect(response.status).to eq(400)
    end
  end

  describe 'DELETE /user_plants' do
    it 'removes the plant from the users list of plants' do
      plant = Plant.create!(plant_type: "Tomato", name: "Sungold", days_relative_to_frost_date: 14, days_to_maturity: 54, hybrid_status: 1)
      user = User.create!(name: "Joel User", email: 'joel@123.com', password: "12345", zip_code: 80123)
      user_plant = UserPlant.create(user_id: user.id, plant_id: plant.id)

      delete "/api/v1/user_plants/#{user_plant.id}" # Would like to refactor this to use params but it does not like them for some reason.
      result = JSON.parse(response.body, symbolize_names: true)

      expect(result[:data][:attributes][:id]).to eq(user_plant.id)
      expect(result[:data][:attributes][:user_id]).to eq(user.id)
      expect(result[:data][:attributes][:plant_id]).to eq(plant.id)
    end
  end
end