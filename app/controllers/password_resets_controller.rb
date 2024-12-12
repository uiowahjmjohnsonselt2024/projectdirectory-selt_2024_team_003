
class PasswordResetsController < ApplicationController
  before_action :find_user_by_token, only: [:update, :edit]

  def new
  end

  def create
    @user = User.find_by(email: params[:email])
    if @user
      @user.generate_reset_password_token!
      PasswordMailer.reset_password_email(@user).deliver
      flash[:email] = "Email found"
    else
      flash[:email] = "Email not found"
    end
  end

  def edit
  end

  def update
    if @user && @user.update(user_params)
      redirect_to login_path
    else
      flash[:reseterr] = "Could not update password"
    end
  end

  private

  def find_user_by_token
    token = if params[:token] then params[:token] else params[:id] end
    @user = User.find_by(reset_password_token: token)
    if @user.nil? || !@user.reset_password_token_valid?(token)
      flash[:reseterr] = "Reset password link is invalid or expired."
    end
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end


