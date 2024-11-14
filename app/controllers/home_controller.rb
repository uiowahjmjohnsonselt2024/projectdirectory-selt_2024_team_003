class HomeController < ApplicationController
  def index
    #Pass these strings to the view
    @welcome_message = "Welcome to Shards of the Grid!"
    @login_button = "Login"
    @create_button = "Create"
    @copyright_text = "&copy; 2024 Shards of the Grid. All rights reserved."
  end
end
