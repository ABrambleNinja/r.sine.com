# Clone of r.sine.com
# Displays random image when page is loaded
# Coded by ABrambleNinja, released under MIT license
# <http://abrambleninja.mit-license.org>

# Config Variables

IMAGE_DIRECTORY = "images"
IMAGE_EXTENSIONS = ['.jpg', '.jpeg', '.gif', '.png']
SERVER_NAME = "better than urs" # shows up on HTTP headers
NOT_FOUND = "noneed.gif" # image to display on 404

# End Config Variables

$images = []
Dir.foreach(IMAGE_DIRECTORY) do |f|
  next if File.directory?(f) # if f is a directory, skip it
  next unless IMAGE_EXTENSIONS.include? File.extname(f) # if f does not match one of the extensions, skip it
  $images << f
end

require 'sinatra'
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

use ChangeServer

get '/' do
  image = get_image
  send_image image
end

get '/:image' do
  if File.exist? IMAGE_DIRECTORY + "/" + params[:image]
    send_image params[:image]
  else
    halt 404
  end
end

not_found do
  status 404
  send_image NOT_FOUND
end

def get_image
  $images.sample # choose random image
end

def send_image image
  content_type MIME::Types.of(image).first.content_type
  File.open("#{Dir.pwd}/#{IMAGE_DIRECTORY}/#{image}").read # send image to user
end
