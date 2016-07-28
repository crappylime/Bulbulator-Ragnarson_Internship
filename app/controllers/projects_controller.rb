class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:show, :edit, :update, :destroy, :link_contributors]
  before_action only: [:edit, :update, :destroy, :link_contributors] { authorize @project, :modify? }
  before_action only: [:show] { authorize @project, :access? }

  def index
    @projects = Project.all
  end

  def managed
    @projects = current_user.managed_projects.all
  end

  def contributed
    @projects = current_user.contributed_projects.all
  end

  def show
    @active_tasks = @project.tasks.not_done
    @done_tasks = @project.tasks.done

    @events = @project.events
  end

  def new
    @project = current_user.managed_projects.new
  end

  def create
    @project = current_user.managed_projects.new(project_params)
    if @project.create_project(current_user)
      redirect_to @project, notice: "Poject was successfully created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @project.update_and_notify(project_params, current_user, :contributors)
      redirect_to @project, notice: "Poject was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @project.destroy_and_notify(current_user, :contributors)
    redirect_to projects_url, notice: "Poject was successfully destroyed."
  end

  def link_contributors
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title, :description, :date)
  end
end
