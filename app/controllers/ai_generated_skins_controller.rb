class AiGeneratedSkinsController < ApplicationController
  require 'net/http'
  require 'json'
  require 'mini_magick'
  require 'open-uri'

  before_action :check_skin_limit, only: [:generate]

  def new
    # This action simply renders the form
  end

  def generate
    character_description = params[:character_description]
    archetype = params[:archetype]

    # Validate character_description and archetype
    if character_description.blank? || archetype.blank?
      @error = true
      render :new and return
    end

    # Generate the AI Image using OpenAI API
    uri = URI("https://api.openai.com/v1/images/generations")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{ENV['OPENAI_API_KEY']}"
    request['Content-Type'] = 'application/json'
    request.body = {
      prompt: "#{character_description} in a vibrant fantasy style. " \
        "A fully centered #{character_description} on a plain, uniform purple background with no gradients, textures, or patterns. " \
        "The background must be a solid, consistent purple where every pixel is the same shade of purple. " \
        "Ensure the #{character_description} is well-defined, proportionate, and entirely visible within the image. " \
        "IMPORTANT: The #{character_description} must not contain any purple elements, including clothing, accessories, or magical effects. " \
        "Focus on making the #{character_description} visually distinct from the background.",
      n: 1,
      size: "1024x1024"
    }.to_json

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      generated_image_url = data['data'][0]['url']

      # Pass the original image URL to the view
      @original_image_url = generated_image_url

      # Save the processed image in an image object
      processed_image = process_image(generated_image_url)

      # Convert the processed image to a base64 string for embedding directly in the view
      @image_base64 = Base64.strict_encode64(processed_image.to_blob)
    else
      @error = true
    end

    render :new
  end

  private

  # Check if the user has reached the 3-skin limit
  def check_skin_limit
    if current_user.skins.count >= 3
      flash[:notice] = "You already have 3 skins in your inventory. Please delete one before creating a new one."
      redirect_to inventory_index_path
    end
  end

  # Fetch and process the image entirely in memory
  def process_image(image_url)
    image = MiniMagick::Image.read(URI.open(image_url).read)

    # Detect the background color and make it transparent
    remove_background(image)

    image
  end

  # Remove the background using MiniMagick
  def remove_background(image)
    # Get top left corner pixel, assume this is the background, get hex value of color
    background_color = image.get_pixels[0][0]
    hex_color = "##{background_color.map { |c| c.to_s(16).rjust(2, '0') }.join.upcase}"

    # Make the background color transparent
    image.combine_options do |config|
      config.fuzz "25%" # 25% Tolerance
      config.transparent hex_color
    end
  end
end
