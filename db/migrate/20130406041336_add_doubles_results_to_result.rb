class AddDoublesResultsToResult < ActiveRecord::Migration
  def change
    change_table :results do |t|
      t.integer :home_partner_rating
      t.integer :away_partner_rating
      t.references :home_partner
      t.references :away_partner
    end
  end
end
