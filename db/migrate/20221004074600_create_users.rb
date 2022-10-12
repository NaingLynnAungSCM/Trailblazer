class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false, unqiue: true
      t.string :password_digest, null: false
      t.integer :phone
      t.text :address
      t.date :dob
      t.string :user_type, null: false
      t.text :image_data
      t.timestamps
    end
  end
end
