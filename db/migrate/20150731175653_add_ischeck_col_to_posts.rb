class AddIscheckColToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :ischeck, :integer
  end
end
