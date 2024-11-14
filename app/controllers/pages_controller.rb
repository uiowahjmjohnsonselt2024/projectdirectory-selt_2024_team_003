class PagesController < ApplicationController
  # app/controllers/pages_controller.rb
  def grid
    @user_name = "John Doe"
    @profile_picture_url = "/path/to/profile.jpg"
    @stats = [
      { name: "Stat 1", value: 100 },
      { name: "Stat 2", value: 200 },
      { name: "Stat 3", value: 300 }
    ]
  end
end
