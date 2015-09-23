class CreateWordSets < ActiveRecord::Migration
  def change
    create_table :word_sets do |t|
      t.references :word
      t.references :meaning
      t.references :user, index: true
      t.references :list, index: true

      t.timestamps
    end

    change_table :lists do|t|
      t.references :language1
      t.references :language2
    end

  end
end
