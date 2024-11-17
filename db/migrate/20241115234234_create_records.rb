class CreateRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :records do |t|
      t.integer :category, default: 0
      t.float :unit_price, null: false
      t.integer :quantity, null: false
      t.integer :variant_id, null: true
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :status, default: 0
      t.integer :service_item_id, null: true
      t.belongs_to :customer, null: true

      t.timestamps
    end
    add_index :records, :variant_id
    add_index :records, :service_item_id
  end
end
