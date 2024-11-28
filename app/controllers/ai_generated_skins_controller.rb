class AiGeneratedSkinsController < ApplicationController
  #NOTE: http://localhost:3000/ai_generated_skins/generate is route for ai generated images
  require 'net/http'
  require 'json'
  require 'mini_magick'
  require 'open-uri'

  def generate
    #Generate the AI Image using OpenAI API
    uri = URI("https://api.openai.com/v1/images/generations")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)

    #Add authentication key
    request['Authorization'] = "Bearer sk-openAI-API-key here"
    request['Content-Type'] = "application/json"
    request.body = {
      prompt: "A dragon in retro animated style, featuring vibrant colors like red, green, and yellow, " \
        "fully centered on a solid plum purple background with the exact color value of hex #8E4585. " \
        "The dragon should have some pixelation in a clean, detailed style, with defined features and proportions. " \
        "Ensure the entire dragon is visible and does not go off the edges of the image. " \
        "The background should remain plain with no additional features or textures.",
      n: 1,
      size: "1024x1024"
    }.to_json

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      generated_image_url = data['data'][0]['url']

      # Pass the original image URL to the view
      @original_image_url = generated_image_url

      #Save the process image in an image object
      processed_image = process_image(generated_image_url)

      # Convert the processed image to a base64 string for embedding directly in the view - ChatGPT assisted
      @image_base64 = Base64.strict_encode64(processed_image.to_blob)
    else
      @error = "Unable To Generate Skin Image"
    end

    render :show
  end


  private

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
      config.fuzz "10%" # 10% Tolerance
      config.transparent hex_color
    end
  end
end
