class CreateServiceItems < ActiveRecord::Migration[8.0]
  def change
    create_table :service_items do |t|
      t.string :name
      t.text :description
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
