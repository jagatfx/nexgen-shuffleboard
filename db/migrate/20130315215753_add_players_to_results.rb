class AddPlayersToResults < ActiveRecord::Migration
  def change
    change_table :results do |t|
      t.references :home_player
      t.references :away_player
    end
  end
end
