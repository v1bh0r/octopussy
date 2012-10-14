class ApplicationController < ActionController::Base
  protect_from_forgery

  def authenticate
    if current_user.nil?
      flash[:notice] = 'You have to be logged in to access requested page.'
      redirect_to root_path
    end
  end
end
