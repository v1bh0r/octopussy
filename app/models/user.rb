class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :trackable, :omniauthable, :database_authenticatable

  serialize :info, Hash

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :provider, :uid, :oauth_token, :info
  # attr_accessible :title, :body

  attr_accessor :encrypted_password

  def self.find_for_github(access_token)
    if user = User.where(:uid => access_token.uid ).first
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
end
