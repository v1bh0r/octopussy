class Favourite < ActiveRecord::Base
  attr_accessible :project_id, :user_id

  belongs_to :user
end
