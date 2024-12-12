# frozen_string_literal: true

# app/controllers/registrations_controller.rb
class RegistrationsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id # Log the user in after registration
      redirect_to selections_path
    else
      flash.now[:alert] = @user.errors.full_messages[0] # Display the first error
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :avatar)
  end
end
