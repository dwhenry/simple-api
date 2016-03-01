require 'rails_helper'

describe 'game management' do
  let(:user) { User.create(name: 'David', password: 'qwerty123', auth_token: SecureRandom.uuid, auth_token_valid_until: 4.hours.from_now) }

  context 'creating a new game' do
    it 'requires the user to pass an auth_token' do
      expect(post games_path).to eq(400)
      expect(JSON.parse(response.body)).to eq(
        'status' => 'error',
        'messages' => ['user not authorised']
      )
    end

    it 'will default the number of players to 4' do
      post games_path, nil, 'AUTH_TOKEN' => user.auth_token
      response_json = JSON.parse(response.body)
      expect(response_json['data']['players'].count).to eq(4)
    end

    it 'will automatically add you to the game' do
      post games_path, nil, 'AUTH_TOKEN' => user.auth_token
      player_1 = JSON.parse(response.body)['data']['players'][0]
      expect(player_1).to eq(
        "id" => user.id,
        "name" => user.name
      )
    end

    it 'will allow you to set the number of players' do
      post games_path, { players: 5 }, 'AUTH_TOKEN' => user.auth_token
      response_json = JSON.parse(response.body)
      expect(response_json['data']['players'].count).to eq(5)
    end

    xit 'it will return no actions for the current user' do
      post games_path, { players: 5 }, 'AUTH_TOKEN' => user.auth_token
      response_json = JSON.parse(response.body)
      expect(response_json['actions']).to eq([])
    end

    xit 'it will return a leave action for the current user' do
      post games_path, { players: 5 }, 'AUTH_TOKEN' => user.auth_token
      response_json = JSON.parse(response.body)
      expect(response_json['actions']).to eq(['leave'])
    end
  end
  end
end
