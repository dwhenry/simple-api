require 'rails_helper'

describe 'User login and sessions' do
  let!(:user) { User.create(name: 'David', password: 'qwerty123') }

  it 'a user can login with correct credentials' do
    expect(post '/login', name: 'David', password: 'qwerty123').to eq(200)
  end

  it 'a user can not login with incorect credentials' do
    expect(post '/login', name: 'David', password: 'wrong').to eq(400)
    expect(JSON.parse(response.body)).to eq(
      'status' => 'error',
      'messages' => ['Incorrect username or password']
    )
  end

  it 'logging in give the user an auth token' do
    allow(SecureRandom).to receive(:uuid).and_return('apples')
    post '/login', name: 'David', password: 'qwerty123'
    expect(JSON.parse(response.body)).to eq(
      'status' => 'success',
      'auth_token' => 'apples'
    )
  end

  context 'auth_token can be used to access the rest of the system' do
    before do
      post '/login', name: 'David', password: 'qwerty123'
      @auth_token = JSON.parse(response.body)['auth_token']
    end

    it '400 when no auth passed' do
      expect(get games_path).to eq(400)
    end

    it '200 when passed by params' do
      expect(get games_path, auth_token: @auth_token).to eq(200)
    end

    it '200 when passed by headers' do
      expect(get games_path, nil, 'AUTH_TOKEN' => @auth_token).to eq(200)
    end
  end

  it 'requires an auth_token to be valid' do
    expect(get games_path).to eq(400)
  end

  it 'auth_token is valid for 4 hours' do
    post '/login', name: 'David', password: 'qwerty123'
    @auth_token = JSON.parse(response.body)['auth_token']

    travel_to(5.hours.from_now) do
      expect(get games_path, auth_token: @auth_token).to eq(400)
    end
  end

  it 'if the user logs in again a new auth_token is generated' do
    post '/login', name: 'David', password: 'qwerty123'
    auth_token_1 = JSON.parse(response.body)['auth_token']
    post '/login', name: 'David', password: 'qwerty123'
    auth_token_2 = JSON.parse(response.body)['auth_token']

    expect(auth_token_1).not_to eq(auth_token_2)
  end

  it 'logging out invalidates the auth_token'
end
