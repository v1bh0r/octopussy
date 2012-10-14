class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :trackable, :omniauthable, :database_authenticatable

  serialize :info, Hash

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :provider, :uid, :oauth_token, :info
  # attr_accessible :title, :body

  attr_accessor :encrypted_password
  has_many :favourites

  def self.find_for_github(access_token)
    if user = User.where(:uid => access_token.uid).first
      user.update_attributes :oauth_token => access_token['credentials']['token'], :info => access_token['info']
    else
      user = User.create!(:uid => access_token.uid, :oauth_token => access_token['credentials']['token'], :info => access_token['info'])
    end
    user
  end

  def github_client
    Github.new :oauth_token => oauth_token
  end

  def projects
    github_client.repos.all
  end
  def issues project_owner, project_name, milestone_id
  github_client.issues.list_repo project_owner, project_name , :milestone => milestone_id

  end
  def milestones project_owner, project_name
    github_client.issues.milestones.list project_owner, project_name, :state => 'open'
  end

  def all_milestones(owner, project_name)
    github_client.issues.milestones.list(owner, project_name) rescue []
  end

  def collaborators(owner, project_name)
    github_client.repos.collaborators.list(owner, project_name)
  end
end
