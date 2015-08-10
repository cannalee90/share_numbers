class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :mobile
      t.string :name
      t.string :password
      t.string :role
      t.string :school
      t.string :team

      t.timestamps null: false
    end
  end
end
