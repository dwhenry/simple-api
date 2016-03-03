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

  context 'listing player stats for games' do
    it 'will return count games where you are waiting for players to join' do
      Game.create!(state: "CoEngine::WaitingForPlayers", uuid: 'uuid', max_players: 4, players: [ Player.new(user: user) ])

      get games_path, nil, 'AUTH_TOKEN' => user.auth_token
      expect(JSON.parse(response.body)).to eq(
        "playing" => 0,
        "won" => 0,
        "lost" => 0,
        "wainting_for_players" => 1,
        "can_be_joined" => 0
      )
    end

    it 'will return count of playing games' do
      Game.create!(state: "CoEngine::PickTile", uuid: 'uuid', max_players: 4, players: [ Player.new(user: user) ])

      get games_path, nil, 'AUTH_TOKEN' => user.auth_token
      expect(JSON.parse(response.body)).to eq(
        "playing" => 1,
        "won" => 0,
        "lost" => 0,
        "wainting_for_players" => 0,
        "can_be_joined" => 0
      )
    end

    it 'will return count of won games' do
      Game.create!(state: "CoEngine::Completed", winner: user, uuid: 'uuid', max_players: 4, players: [ Player.new(user: user) ])

      get games_path, nil, 'AUTH_TOKEN' => user.auth_token
      expect(JSON.parse(response.body)).to eq(
        "playing" => 0,
        "won" => 1,
        "lost" => 0,
        "wainting_for_players" => 0,
        "can_be_joined" => 0
      )
    end

    it 'will return count of lost games' do
      Game.create!(state: "CoEngine::Completed", winner: nil, uuid: 'uuid', max_players: 4, players: [ Player.new(user: user) ])

      get games_path, nil, 'AUTH_TOKEN' => user.auth_token
      expect(JSON.parse(response.body)).to eq(
        "playing" => 0,
        "won" => 0,
        "lost" => 1,
        "wainting_for_players" => 0,
        "can_be_joined" => 0
      )
    end

    it 'will return count of joinable games' do
      Game.create!(state: "CoEngine::WaitingForPlayers", uuid: 'uuid', max_players: 4, players: [  ])

      get games_path, nil, 'AUTH_TOKEN' => user.auth_token
      expect(JSON.parse(response.body)).to eq(
        "playing" => 0,
        "won" => 0,
        "lost" => 0,
        "wainting_for_players" => 0,
        "can_be_joined" => 1
      )
    end
  end

  context '#list of game for a given state' do
    context 'for the playing state' do
      before do
        Game.create!(state: "CoEngine::PickTile", uuid: 'uuid', max_players: 4, players: [
          Player.new(user: user),
          Player.new(user: User.create(name: 'Fred', password: 'qwerty123')),
          Player.new(user: User.create(name: 'John', password: 'qwerty123'))
        ])
      end

      it 'return details for each game the current user is playing' do
        get game_path('playing'), nil, 'AUTH_TOKEN' => user.auth_token

        expect(JSON.parse(response.body)).to eq(
          "playing" => [
            { "id" => "uuid", "max_players" => 4, "players" => [ "David", "Fred", "John" ], "winner" => nil }
          ]
        )
      end
    end

    context 'for the won state' do
      before do
        Game.create!(state: "CoEngine::Completed", uuid: 'uuid', max_players: 4, winner: user, players: [
          Player.new(user: user),
          Player.new(user: User.create(name: 'Fred', password: 'qwerty123')),
          Player.new(user: User.create(name: 'John', password: 'qwerty123'))
        ])
      end

      it 'return details for each game the current user has won' do
        get game_path('won'), nil, 'AUTH_TOKEN' => user.auth_token

        expect(JSON.parse(response.body)).to eq(
          "won" => [
            { "id" => "uuid", "max_players" => 4, "players" => [ "David", "Fred", "John" ], "winner" => "David" }
          ]
        )
      end
    end

    context 'for an invalid state' do
      it 'raises an error' do
        expect { get game_path('parts'), nil, 'AUTH_TOKEN' => user.auth_token }.to raise_error("Unknown game state: parts")
      end
    end
  end
end
