class Group < ActiveRecord::Base  
  has_many :group_memberships, class_name:  "GroupMembership",
                               foreign_key: :group_id,
                               dependent:   :destroy  
  has_many :members, through: :group_memberships, source: :user
  
  has_one :faker, class_name: :User
  
  validates :name, presence: true
  
  def has_list?(list)
    return list.owner_id = self.faker_id    
  end
end
