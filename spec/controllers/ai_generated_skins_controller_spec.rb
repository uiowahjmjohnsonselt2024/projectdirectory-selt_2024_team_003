# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AiGeneratedSkinsController, type: :controller do
  describe 'GET #generate' do
    let(:generated_image_url) { 'https://example.com/generated_image.png' }
    let(:api_response) do
      {
        data: [
          { url: generated_image_url }
        ]
      }.to_json
    end

    before do
      # Mock OpenAI API request
      stub_request(:post, 'https://api.openai.com/v1/images/generations')
        .with(
          headers: {
            'Authorization' => 'Bearer sk-openAI-API-key here',
            'Content-Type' => 'application/json'
          },
          body: {
            prompt: a_string_including('A dragon in retro animated style'),
            n: 1,
            size: '1024x1024'
          }.to_json
        )
        .to_return(status: 200, body: api_response, headers: { 'Content-Type' => 'application/json' })

      # Mock URI.open to fetch the generated image
      allow(URI).to receive(:open).with(generated_image_url).and_return(StringIO.new('image_data'))

      # Mock MiniMagick image processing
      processed_image = instance_double(MiniMagick::Image)
      allow(MiniMagick::Image).to receive(:read).and_return(processed_image)
      allow(processed_image).to receive(:get_pixels).and_return([[255, 255, 255]])
      allow(processed_image).to receive(:combine_options)
    end

    it 'returns a success response' do
      get :generate
      expect(response).to be_successful
    end

    it 'assigns the original image URL' do
      get :generate
      expect(assigns(:original_image_url)).to eq(generated_image_url)
    end

    it 'renders the :show template' do
      get :generate
      expect(response).to render_template(:show)
    end
  end
end
