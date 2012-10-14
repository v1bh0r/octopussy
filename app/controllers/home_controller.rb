class HomeController < ApplicationController
  before_filter :when_logged_in

  def index
  end

  private
  def when_logged_in
    redirect_to project_index_path if user_signed_in?
  end
end
