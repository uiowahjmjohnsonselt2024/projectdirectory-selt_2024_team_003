class HomeController < ApplicationController
  def index
    redirect_to games_path if logged_in?
    # Pass these strings to the view
    @welcome_message = 'Shards of the Grid!'
    @login_button = 'Login'
    @create_button = 'Create'
    @copyright_text = '&copy; 2024 Shards of the Grid. All rights reserved.'
  end
end
