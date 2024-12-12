# frozen_string_literal: true

class ProtectedController < ApplicationController
  before_action :require_login

  private

  def require_login
    return if logged_in?

    redirect_to login_path, alert: 'You must be logged in to access this page.'
  end
end
