class PasswordMailer < ApplicationMailer
  default from: "notifications@example.com"

  def reset_password_email(user)
    @user = user
    mail(to: @user.email, subject: "ShardsOfTheGrid Password Reset")
  end
end
