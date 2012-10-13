class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :trackable, :omniauthable, :database_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :provider, :uid, :oauth_token
  # attr_accessible :title, :body

  attr_accessor :github_info, :encrypted_password

  def self.find_for_github(access_token)
    if user = User.where(:provider => access_token.provider, :uid => access_token.uid ).first
      user.update_attributes :oauth_token => access_token['credentials']['token']
    else
      user = User.create!(:provider => access_token.provider, :uid => access_token.uid, :oauth_token => access_token['credentials']['token'])
    end
    user.github_info = access_token['info']
    user
  end
end
