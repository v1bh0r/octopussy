class ProjectController < ApplicationController
  def index
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

  def fetch_projects
    @projects = current_user.projects
    render :partial => 'projects_thumbnail', :locals => { :projects => @projects }
  end

  def milestones
    @milestones = current_user.all_milestones params[:owner], params[:name]
  end
end
