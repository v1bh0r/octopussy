require 'github'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :trackable, :omniauthable, :database_authenticatable

  serialize :info, Hash

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :provider, :uid, :oauth_token, :info
  # attr_accessible :title, :body

  attr_accessor :encrypted_password
  has_many :favourites, :dependent => :destroy

  def self.find_for_github(access_token)
    if user = User.where(:uid => access_token.uid).first
      user.update_attributes :oauth_token => access_token['credentials']['token'], :info => access_token['info']
    else
      user = User.create!(:uid => access_token.uid, :oauth_token => access_token['credentials']['token'], :info => access_token['info'])
    end
    user
  end

  def github_client
    Github.new oauth_token
  end

  def projects
    projects = github_client.repos :params => {:sort => 'updated'}
    favorites = self.favourites.all(:select => 'project_id').collect { |fav| fav.project_id }
    projects.map! { |project| favorites.include?(project[:id]) ? project.merge(:favorite => true) : project }
  end

  def issues(project_owner, project_name, milestone_id)
    github_client.issues project_owner, project_name, :params => {:milestone => milestone_id}
  end

  def milestones(project_owner, project_name, state = 'open')
    github_client.milestones project_owner, project_name, :params => {:state => state}
  end

  def all_milestones(project_owner, project_name)
    milestones(project_owner, project_name, 'open') + milestones(project_owner, project_name, 'closed')
  end

  def collaborators(project_owner, project_name)
    github_client.collaborators(project_owner, project_name)
  end
end
