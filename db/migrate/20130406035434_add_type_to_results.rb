class AddTypeToResults < ActiveRecord::Migration
  def change
    add_column :results, :type, :string
  end
end
