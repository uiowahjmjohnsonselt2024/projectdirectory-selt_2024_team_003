class WaitingRoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "waiting_room" # Everyone in the room streams from the same broadcast
  end

  def unsubscribed
    # Cleanup once a user disconnects, if needed
  end

  def start_event
    # Notify all users in the waiting room that the event has started
    ActionCable.server.broadcast "waiting_room", { message: "The game is starting now!" }
    head :ok
  end
end