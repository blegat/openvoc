class CreateInclusions < ActiveRecord::Migration
  def change
    create_table :inclusions do |t|
      t.references :list
      t.references :word
      t.references :author

      t.timestamps
    end
    add_index :inclusions, :list_id
  end
end
