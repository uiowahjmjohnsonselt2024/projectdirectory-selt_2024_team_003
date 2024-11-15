# frozen_string_literal: true

class GameUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
end
