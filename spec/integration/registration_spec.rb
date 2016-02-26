require 'rails_helper'

describe 'User registration' do
  it 'a new user can register with the api' do
    expect {
      post '/register', name: 'David', password: 'qwerty123'
    }.to change {
      User.count
    }.by(1)
  end

  it 'returns the errors message if unsuccessful' do
    expect(post '/register').to eq(400)
    expect(JSON.parse(response.body)).to eq(
      "status" => "error",
      "messages" => [
        "Name must be at least 4 characters",
        "Password must be at least 6 characters",
        "Password must contain a mix of letters and numbers"
      ]
    )
  end

  it 'does not allow a user to register with an existing user ID (name)' do
    User.create!(name: 'David', password: '123qwe')
    expect(post '/register', name: 'David', password: 'qwerty123').to eq(400)
    expect(JSON.parse(response.body)).to eq(
      "status" => "error",
      "messages" => [
        "Name has already been registered",
      ]
    )
  end
end
