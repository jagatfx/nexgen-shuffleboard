class AddRatingChangeToResults < ActiveRecord::Migration
  def change
    add_column :results, :rating_change, :integer
  end
end
