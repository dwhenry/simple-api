class User < ActiveRecord::Base
  validates_uniqueness_of :name, message: 'has already been registered'
  validates_length_of :name, minimum: 4, message: 'must be at least 4 characters'
  validates_length_of :password, minimum: 6, message: 'must be at least 6 characters'
  validates_format_of :password, with: %r{(?=.*[a-z])(?=.*[0-9])}, message: 'must contain a mix of letters and numbers'
  validates_format_of :password, without: %r{(?=(.)\1\1)}, message: 'can not contain more than two consecutive characters'

  def authenticate(password)
    self.password == password
  end
end
