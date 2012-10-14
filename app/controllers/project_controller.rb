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
    render :partial => 'projects_thumbnail'
  end

  def milestones
    @milestones = current_user.milestones params[:owner], params[:name]
  end

  def tasks
    @tasks = current_user.issues params[:owner], params[:name], params[:milestone]
  end

  def fetch_progress
    owner_login = params[:owner]
    project_name = params[:project_name]

    completed_percentage = 0
    milestones = current_user.all_milestones(owner_login, project_name)

    milestones.each do |milestone|
      completed_percentage += milestone[:open_issues] > 0 ? ((milestone[:closed_issues] * 100)/milestone[:open_issues]).to_i : 100
    end

    render :json => { :total => milestones.count, :completeness => (milestones.present? ? completed_percentage/milestones.count : 0) }
  end

end
