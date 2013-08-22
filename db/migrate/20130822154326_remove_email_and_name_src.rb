class RemoveEmailAndNameSrc < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.remove :name_src
      t.remove :email_src
    end
  end

  def down
    change_table :users do |t|
      t.references :name_src
      t.references :email_src
    end
  end
end
