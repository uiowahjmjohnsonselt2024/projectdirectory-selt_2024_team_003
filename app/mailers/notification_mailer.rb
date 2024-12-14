class NotificationMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def purchase_notification(user, shard_count)
    @user = user
    @shard_count = shard_count
    mail(to: @user.email, subject: 'Purchase Confirmation')
  end

  def signup_notification(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to Shards Of The Grid')
  end
end

