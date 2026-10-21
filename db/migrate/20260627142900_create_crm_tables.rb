class CreateCrmTables < ActiveRecord::Migration[8.1]
  def change
    create_table :clients do |t|
      t.string :firstname, null: false
      t.string :lastname, null: false
      t.string :phone
      t.string :email
      t.timestamps
    end

    create_table :pets do |t|
      t.references :client, null: false, foreign_key: true
      t.string :name, null: false
      t.string :species, null: false
      t.string :breed
      t.date :birth_date
      t.timestamps
    end

    create_table :pet_histories do |t|
      t.references :pet, null: false, foreign_key: true
      t.datetime :visit_date, null: false
      t.timestamps
    end

    create_table :treatments do |t|
      t.references :pet_history, null: false, foreign_key: true
      t.text :notes
      t.timestamps
    end

    create_table :recommendations do |t|
      t.references :pet_history, null: false, foreign_key: true
      t.text :notes
      t.timestamps
    end

    create_table :analysis_types do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :description
      t.timestamps
    end

    create_table :analyses do |t|
      t.references :pet_history, null: false, foreign_key: true
      t.references :analysis_type, null: false, foreign_key: true
      t.text :result
      t.timestamps
    end
  end
end
