class SelectionsController < ApplicationController
  def index
  end

  def update_archetype
    archetype = params[:archetype]

    # Call the method on the current user to set the archetype and stats
    current_user.set_archetype_stats(archetype)

    render json: { success: true }
  rescue => e
    render json: { success: false, error: e.message }
  end
end
