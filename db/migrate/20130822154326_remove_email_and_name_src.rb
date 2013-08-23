class RemoveEmailAndNameSrc < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.remove :name_src_id
      t.remove :email_src_id
    end
  end

  def down
    change_table :users do |t|
      t.references :name_src
      t.references :email_src
    end
  end
end
