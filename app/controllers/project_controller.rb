class ProjectController < ApplicationController
  def index
    @projects = current_user.projects
  end

  def show
  end

  def toggle_fav
    if params[:fav] == 'true'
      current_user.favourites.create(:project_id => params[:id])
    else
      fav = current_user.favourites.find_by_project_id(params[:id])
      fav.delete unless fav.nil?
    end
    render :json => :ok
  end
end
