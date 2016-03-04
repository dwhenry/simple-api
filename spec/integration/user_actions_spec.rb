require 'rails_helper'

describe 'User actions within the game' do
  let(:uuid) { SecureRandom.uuid }
  let(:user) do
    user = User.find_by!(name: 'john')
    user.authenticate!('qwert123')
    user
  end
  let(:bob) do
    user = User.find_by!(name: 'bob')
    user.authenticate!('qwert123')
    user
  end

  before do
    game_json = File.read("#{fixture_path}/picked-game-tile.json")
    engine = CoEngine.load(game_json)

    Redis.new.set(uuid, game_json)

    game = Game.create!(uuid: uuid, state: engine.state, max_players: engine.players.count)
    engine.players.each do |player|
      game.users.find_or_create_by!(id: player.id, name: player.name, password: 'qwert123')
    end
  end

  it 'will successfully perform a valid action for the current player' do
    put(
      "/actions/#{uuid}",
      { perform: :guess, args: { player: 'bob', tile_position: 1, color: 'black', value: 11 } },
      'AUTH_TOKEN' => user.auth_token
    )
    expect(JSON.parse(response.body)).to include(
      "game_id" => uuid,
      "actions" => ["finalize_hand", "move_tile"]
    )
  end

  it 'will return error json on invalid action for the current player' do
    expect(
      put "/actions/#{uuid}", { perform: :finalize_hand}, 'AUTH_TOKEN' => user.auth_token
    ).to eq(400)
    expect(JSON.parse(response.body)).to eq(
      "status" => 'error',
      "messages" => ['ActionCanNotBePerformed: finalize_hand']
    )
  end

  it 'will raise an error on valid action for an invalid player' do
    expect(
      put(
        "/actions/#{uuid}",
        { perform: :guess, args: { player: 'bob', tile_position: 1, color: 'black', value: 11 } },
        'AUTH_TOKEN' => bob.auth_token
      )
    ).to eq(400)
    expect(JSON.parse(response.body)).to eq(
      "status" => 'error',
      "messages" => ['NotYourTurn']
    )
  end

  it 'will raise an error if game does not exist' do
    expect(
      put(
        "/actions/1234",
        { perform: :guess, args: { player: 'bob', tile_position: 1, color: 'black', value: 11 } },
        'AUTH_TOKEN' => bob.auth_token
      )
    ).to eq(400)
    expect(JSON.parse(response.body)).to eq(
      "status" => 'error',
      "messages" => ['GameNotFound']
    )
  end
end
