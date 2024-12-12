# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  describe 'GET /grid' do
    it 'returns http success' do
      get '/pages/grid'
      expect(response).to have_http_status(:success)
    end
  end
end
