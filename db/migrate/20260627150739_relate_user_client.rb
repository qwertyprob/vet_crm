class RelateUserClient < ActiveRecord::Migration[8.1]
  def change
    add_reference :clients, :user, null: false, foreign_key: true
    remove_column :clients, :phone, :string
    remove_column :clients, :email, :string
  end
end
