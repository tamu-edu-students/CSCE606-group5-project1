class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :netid
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :role
      t.datetime :last_login_at

      t.timestamps
    end
  end
end
