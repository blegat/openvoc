class AddConfidenceToLinks < ActiveRecord::Migration
  def change
    change_table :meanings do |t|
      t.integer :pro
      t.integer :contra
      t.float   :confidence
    end
  end
end
