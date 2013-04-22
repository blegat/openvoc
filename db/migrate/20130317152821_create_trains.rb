class CreateTrains < ActiveRecord::Migration
  def change
    create_table :trains do |t|
      t.references :user
      t.references :word
      t.string :guess
      t.boolean :success

      t.timestamps
    end
    add_index :trains, :user_id
    add_index :trains, :word_id
  end
end
