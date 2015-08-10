class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :context
      t.timestamps null: false
    end
  end
end
