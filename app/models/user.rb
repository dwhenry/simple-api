class User < ActiveRecord::Base
  class InvalidUsernameOrPassword < StandardError; end
  has_many :players
  has_many :games, through: :players
  AUTH_TOKEN_TIMEOUT = 4

  validates_uniqueness_of :name, message: 'has already been registered'
  validates_length_of :name, minimum: 3, message: 'must be at least 4 characters'
  validates_length_of :password, minimum: 6, message: 'must be at least 6 characters'
  validates_format_of :password, with: %r{(?=.*[a-z])(?=.*[0-9])}, message: 'must contain a mix of letters and numbers'
  validates_format_of :password, without: %r{(?=(.)\1\1)}, message: 'can not contain more than two consecutive characters'

  def self.authenticate(auth_token)
    return nil if auth_token.blank?
    user = self.find_by(auth_token: auth_token)
    user.auth_token_valid_until > Time.now ? user : nil
  end

  def self.by_name(name)
    self.find_by(name: name) || raise(User::InvalidUsernameOrPassword)
  end

  def authenticate!(password)
    if self.password == password
      self.auth_token = SecureRandom.uuid
      self.auth_token_valid_until = AUTH_TOKEN_TIMEOUT.hours.from_now
      self.save!
    else
      raise InvalidUsernameOrPassword
    end
  end
end
