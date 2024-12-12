# frozen_string_literal: true
class UserController < ApplicationController
  before_action :authenticate_user!

  # Displays the user's profile, including their current skin stats and friend list
  def index
    @image = case current_user.archetype
             when 'Arcane Strategist'
               'attack.png'
             when 'Iron Guardian'
               'defense.png'
             when 'Omni Knight'
               'balanced.png'
             else
               'balanced.png'
             end

    @stats = [
      { name: "Archetype", value: current_user.current_skin.archetype },
      { name: "Max Health", value: current_user.current_skin.health },
      { name: "Max Mana", value: current_user.current_skin.mana },
      { name: "Attack", value: current_user.current_skin.attack },
      { name: "Special Attack", value: current_user.current_skin.special_attack },
      { name: "Defense", value: current_user.current_skin.defense },
      { name: "Special Defense", value: current_user.current_skin.special_defense },
      { name: "IQ", value: current_user.current_skin.iq },
      { name: "Level", value: current_user.current_skin.level },
      { name: "Experience", value: current_user.current_skin.experience }
    ]

    @users = if params[:search].present?
               User.where('username LIKE ?', "%#{params[:search]}%").where.not(id: current_user.id)
             else
               User.where.not(id: current_user.id)
             end
  end

  def add_friend
    friend = User.find(params[:friend_id])

    if current_user.friends.include?(friend)
      flash[:alert] = "#{friend.username} is already your friend."
    else
      current_user.friendships.create(friend: friend)
      flash[:notice] = "#{friend.username} has been added to your friends list!"
    end

    redirect_to account_path
  end

  def remove_friend
    friend = User.find(params[:friend_id])

    friendship = current_user.friendships.find_by(friend: friend)
    if friendship
      friendship.destroy
      flash[:notice] = "#{friend.username} has been removed from your friends list."
    else
      flash[:alert] = "#{friend.username} is not your friend."
    end

    redirect_to account_path
  end
end
