class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.string :type
      t.references :user, null: false, foreign_key: true
      t.integer :message_type, null: false
      t.integer :delivery_type, null: false
      t.references :subjectable, polymorphic: true, null: true

      t.timestamps
    end
  end
end
