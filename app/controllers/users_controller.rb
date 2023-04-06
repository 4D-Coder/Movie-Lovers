# frozen_string_literal: true

# app/controllers/users_controller.rb
class UsersController < ApplicationController
  def show
    if current_user
      @user = User.find(params[:id])
      @host_viewing_parties = ViewingParty.host_viewing_parties(@user)
      @invited_viewing_parties = ViewingParty.invited_viewing_parties(@user)
      @movies = MovieFacade.new.viewing_party_movies(ViewingParty.list_movie_ids(@user))
    else
      redirect_to root_path
      flash[:error] = "You must be logged in or registered to access your dashboard."
    end
  end

  def new
  end

  def create
    @new_user = User.new(user_params)

    if @new_user.valid? && user_params[:password] == user_params[:password_confirmation]
      @new_user.save
      session[:user_id] = @new_user.id
      redirect_to user_path(@new_user.id)
      flash[:success] = "Welcome, #{@new_user.name}!"
    elsif user_params[:password] != user_params[:password_confirmation]
      redirect_to register_path
      flash[:alert] = "Passwords have to match"
    else
      redirect_to register_path
      flash[:errors] = @new_user.errors.full_messages.join(', ')
    end
  end

  def login_form
  end

  def login_user
    user = User.find_by(email: user_params[:email])
    
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:success] = "Welcome, #{user.name}!"
      redirect_to user_path(user.id)
    else
      flash[:error] = "Bad login credentials, please try again."
      render :login_form
    end
  end

  def logout_user
    session.delete(:user_id)
    # reset_session
    redirect_to root_path
  end

  private

  def user_params
    params.permit(
      :name,
      :email,
      :password,
      :password_confirmation,
      :user_id
    )
  end
end
