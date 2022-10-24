# frozen_string_literal: true

class RepositoriesController < ApplicationController
  before_action :set_repository, only: %i[show edit update destroy]
  before_action :set_organization, only: %i[new show edit update]

  # GET /repositories or /repositories.json
  def index
    @repositories = Repository.all.order(:owner, :name)
  end

  # GET /repositories/1 or /repositories/1.json
  def show
    redirect_to edit_repository_url(@repository)
  end

  # GET /repositories/new
  def new
    @repository = Repository.new
  end

  # GET /repositories/1/edit
  def edit; end

  # POST /repositories or /repositories.json
  def create
    @repository = CreateRepositoryService.call(repository_params)

    respond_to do |format|
      if @repository.errors.size.zero?
        format.html { redirect_to edit_repository_url(@repository.id), notice: 'Repository was successfully created.' }
        format.json { render :show, status: :created, location: @repository }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @repository.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /repositories/1 or /repositories/1.json
  def update
    respond_to do |format|
      if @repository.update(repository_params)
        format.html { redirect_to repository_url(@repository), notice: 'Repository was successfully updated.' }
        format.json { render :show, status: :ok, location: @repository }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @repository.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /repositories/1 or /repositories/1.json
  def destroy
    @repository.destroy

    respond_to do |format|
      format.html { redirect_to repositories_url, notice: 'Repository was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_repository
    @repository = Repository.find(params[:id])
  end

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  # Only allow a list of trusted parameters through.
  def repository_params
    params.require(:repository).permit!
  end
end
