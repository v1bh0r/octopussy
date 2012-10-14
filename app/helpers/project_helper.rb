module ProjectHelper
  def progress(owner_login, project_name)
    completed_percentage = 0
    milestones = current_user.all_milestones(owner_login, project_name)

    milestones.each do |milestone|
      completed_percentage += milestone[:open_issues] > 0 ? ((milestone[:closed_issues] * 100)/milestone[:open_issues]).to_i : 100
    end

    milestones.present? ? completed_percentage/milestones.count : 0
  end
end
