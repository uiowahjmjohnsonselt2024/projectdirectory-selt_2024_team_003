require 'mini_magick'

class BackgroundRemover
  def self.remove_background(input_filename, output_filename)
    script_directory = File.dirname(__FILE__)

    input_path = File.join(script_directory, input_filename)
    output_path = File.join(script_directory, output_filename)


    image = MiniMagick::Image.open(input_path)

    # Process the image to make the background transparent
    image.combine_options do |config|
      config.fuzz "20%"           # Adjust tolerance for color variations
      config.trim                 # Remove surrounding whitespace
      config.transparent "white"  # Make white color fully transparent
    end


    image.write(output_path)

    puts "Image processed and saved to: #{output_path}"
  end
end

