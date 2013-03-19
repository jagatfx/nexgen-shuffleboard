class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.integer :home_score
      t.integer :away_score
      t.integer :home_rating
      t.integer :away_rating

      t.timestamps
    end
  end
end
