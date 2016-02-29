class AddAuthTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :auth_token, :string
    add_column :users, :auth_token_valid_until, :datetime
  end
end
