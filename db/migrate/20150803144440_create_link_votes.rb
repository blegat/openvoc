class CreateLinkVotes < ActiveRecord::Migration
  def change
    create_table :link_votes do |t|
      t.integer :link_id
      t.integer :user_id
      t.boolean :pro
      t.timestamps
    end
    add_index :link_votes, :link_id
    add_index :link_votes, :user_id
    
    
    create_table :groups do |t|
      t.string :name
      t.integer :faker_id
      t.boolean :public
      t.timestamps
    end
    
    
    create_table :group_memberships do |t|
      t.integer :group_id
      t.integer :user_id
      t.boolean :admin, default: false
      
      t.timestamps
    end
    
    change_table :users do |t|
      t.boolean :faker
      t.integer :faker_for_group
    end
    
    reversible do |change|
      change.up do
        User.all.each do |u|
          u.faker = false
          u.save!
        end
      end
    end
    
    
    add_index :group_memberships, :group_id
    add_index :group_memberships, :user_id
    add_index :group_memberships, [:group_id, :user_id], unique: true
  end
end
