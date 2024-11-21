require 'mini_magick'

class BackgroundRemover
  def self.remove_background(input_filename, output_filename)
    script_directory = File.dirname(__FILE__)

    input_path = File.join(script_directory, input_filename)
    output_path = File.join(script_directory, output_filename)

    image = MiniMagick::Image.open(input_path)

    # Process the image to make the specified purple color transparent
    image.combine_options do |config|
      config.fuzz "10%"           # Adjust tolerance for color variations
      config.transparent "#68336B"  # Make the specified purple color transparent
    end

    image.write(output_path)

    puts "Image processed and saved to: #{output_path}"
  end
end
