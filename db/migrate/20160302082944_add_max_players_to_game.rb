class AddMaxPlayersToGame < ActiveRecord::Migration
  def change
    add_column :games, :max_players, :integer
  end
end
