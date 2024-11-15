# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by("email = ? OR username = ?", params[:login], params[:login])

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to games_path, notice: "Logged in successfully."
    else
      flash.now[:alert] = "Invalid login credentials."
      render :new
    end
  end

  def destroy
    session[:user_id] = nil  # Clear the session, effectively logging the user out
    redirect_to root_path, notice: "Logged out successfully."
  end
end