class TrainFragment < ActiveRecord::Base
  belongs_to :train, class_name: "Train"
  validates :train, presence: true
end
