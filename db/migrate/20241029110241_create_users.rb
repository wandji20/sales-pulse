class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.string :full_name
      t.string :telephone, null: true

      t.timestamps
    end
    add_index :users, :email_address, unique: true
    add_index :users, :telephone, unique: true
  end
end
