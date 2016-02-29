require 'rails_helper'

describe 'game management' do
  context 'creating a new game' do
    it 'requires the user to pass an auth_token' do
      post '/games'
      expect(JSON.parse(response.body)).to eq(
        'status' => 'error',
        'messages' => ['user not authorised']
      )
    end
  end
end
