class CreateVariants < ActiveRecord::Migration[8.0]
  def change
    create_table :variants do |t|
      t.string :name
      t.float :price
      t.integer :quantity, default: 0
      t.integer :product_id, null: false
      t.integer :previous_quantity
      t.integer :stock_threshold

      t.timestamps
    end
    add_index :variants, %i[name product_id], unique: true
  end
end
