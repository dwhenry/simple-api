require 'rails_helper'

describe User do
  context 'password validations' do
    it 'must be at least 6 characters' do
      user = User.new(name: 'Dave', password: 'abcd5')
      user.valid?
      expect(user.errors.full_messages).to include('Password must be at least 6 characters')
    end

    it 'must contain letters' do
      user = User.new(name: 'Dave', password: '123456')
      user.valid?
      expect(user.errors.full_messages).to include('Password must contain a mix of letters and numbers')
    end

    it 'must contain numbers' do
      user = User.new(name: 'Dave', password: 'qwerty')
      user.valid?
      expect(user.errors.full_messages).to include('Password must contain a mix of letters and numbers')
    end

    it 'can not contain more than 2 consecutive charcters' do
      user = User.new(name: 'Dave', password: '1aaa2f')
      user.valid?
      expect(user.errors.full_messages).to include('Password can not contain more than two consecutive characters')
    end

    it 'accepts a valid password' do
      user = User.new(name: 'Dave', password: 'qwerty123')
      expect(user).to be_valid
    end
  end

  describe '#authentification' do
    it 'checks the password matches' do
      user = User.new(name: 'Dave', password: 'abcde5')
      expect(user.authenticate('abcde5')).to be true
      expect(user.authenticate('other1')).to be false
    end
  end
end
