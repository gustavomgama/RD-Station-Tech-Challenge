class AddAbandonedToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :abandoned, :boolean, default: false, null: false
    add_index :carts, :abandoned
    add_index :carts, [:abandoned, :updated_at]
  end
end
