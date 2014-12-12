# Clone of r.sine.com
# Displays random image when page is loaded
# Coded by ABrambleNinja, released under MIT license
# <http://abrambleninja.mit-license.org>

# Config Variables

IMAGE_DIRECTORY = "images"
IMAGE_EXTENSIONS = ['.jpg', '.jpeg', '.gif', '.png']
SERVER_NAME = "better than urs" # shows up on HTTP headers

# End Config Variables

require 'sinatra/base'
require 'thin'
require 'mime/types'

class ChangeServer
  def initialize(app)
    @app = app
  end

  def call(env)
    res = @app.call(env)
    res[1]['Server'] = SERVER_NAME
    return res
  end
end

class Sine < Sinatra::Application

  use ChangeServer

  get '/' do
    image = get_image
    content_type MIME::Types.of(image).first.content_type
    File.open("./#{IMAGE_DIRECTORY}/#{image}").read # send image to user
  end

  not_found do
    content_type "text/plain"
    "no u"
  end

  def get_image
    images = []
    Dir.foreach(IMAGE_DIRECTORY) do |f|
      next if File.directory?(f) # if f is a directory, skip it
      next unless IMAGE_EXTENSIONS.include? File.extname(f) # if f does not match one of the extensions, skip it
      images << f
    end
    images.sample # choose random image
  end

end
