# Controller handling user management operations
# Provides CRUD operations for users and profile management functionality
class UsersController < ApplicationController
  # Set up user instance for actions that need a specific user
  before_action :set_user, only: %i[ show edit update destroy ]

  # GET /users or /users.json
  # Display list of all users in the system
  def index
    @users = User.all
  end

  # GET /users/1 or /users/1.json
  # Display details of a specific user
  def show
  end

  # GET /profile
  # Handle user profile viewing and updating
  # Supports both GET (view) and PATCH (update) requests
  def profile
    if request.patch?
      # Handle profile update request
      if current_user.update(user_params)
        redirect_to profile_path, notice: "Profile updated successfully"
      else
        # Re-render profile form with validation errors
        render :profile
      end
    end
    # For GET requests, just render the profile view
  end

  # GET /users/new
  # Display form for creating a new user
  def new
    @user = User.new
  end

  # GET /users/1/edit
  # Display form for editing an existing user
  def edit
  end

  # POST /users or /users.json
  # Create a new user with provided parameters
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        # Success: redirect to user page with success message
        format.html { redirect_to @user, notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        # Failure: re-render form with validation errors
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  # Update an existing user with provided parameters
  def update
    respond_to do |format|
      if @user.update(user_params)
        # Success: redirect to user page with success message
        format.html { redirect_to @user, notice: "User was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @user }
      else
        # Failure: re-render edit form with validation errors
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  # Delete a user from the system
  def destroy
    @user.destroy!

    respond_to do |format|
      # Success: redirect to users index with confirmation message
      format.html { redirect_to users_path, notice: "User was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # Find and set the user instance for actions that operate on a specific user
    def set_user
      @user = User.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    # Define which user attributes can be mass-assigned for security
    def user_params
      params.expect(user: [ :netid, :email, :first_name, :last_name, :role, :last_login_at, :leetcode_username, :personal_email ])
    end
end
