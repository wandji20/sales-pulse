class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.belongs_to :user, null: false, foreign_key: true
      t.boolean :archived, default: false
      t.belongs_to :archived_by, null: true
      t.datetime :archived_on

      t.timestamps
    end
    add_index :products, :name, unique: true
  end
end
