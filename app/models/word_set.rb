class WordSet < ActiveRecord::Base
  belongs_to :user
  belongs_to :list
  
  validates :user_id, presence: true
  #validates :list_id, presence: true
  validates :word1_id, presence: true
  validates :word2_id, presence: true
  #validates :meaning1_id, presence: true
  #validates :meaning2_id, presence: true
  
  def compute_ratios
    compute_ratio_qa
    compute_ratio_aq
  end
  
  def compute_ratio_qa
    if self.asked_qa != 0
      self.success_ratio_qa = 100 * self.success_qa/ self.asked_qa
    else
      self.success_ratio_qa = 0
    end
    self.save
  end
  
  def compute_ratio_aq
    if self.asked_aq != 0
      self.success_ratio_aq = 100 * self.success_aq/ self.asked_aq
    else
      self.success_ratio_aq = 0
    end
    self.save
  end

end
