class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :uuid
      t.string :state
      t.references :winner, index: true, references: :user

      t.timestamps null: false
    end
  end
end
