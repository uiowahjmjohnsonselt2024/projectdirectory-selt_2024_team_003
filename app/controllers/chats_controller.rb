class ChatsController < ApplicationController
  # Displays the chat between current_user and their friend
  def show
    @friend = User.find(params[:friend_id])
    @messages = Message
                .where(user: current_user, recipient: @friend)
                .or(Message.where(user: @friend, recipient: current_user))
                .order(created_at: :asc)
    @new_message = Message.new
  end

  # Handles sending a message
  def create
    @message = current_user.sent_messages.build(message_params)
    @message.recipient_id = params[:friend_id]

    if @message.save
      flash[:notice] = 'Message sent!'
    else
      flash[:alert] = 'Failed to send the message.'
    end
    redirect_to chat_with_user_path(friend_id: params[:friend_id])
  end

  def mark_as_read
    @friend = User.find(params[:friend_id])
    Message.where(user: @friend, recipient: current_user, read: false).update_all(read: true)
    head :ok
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
