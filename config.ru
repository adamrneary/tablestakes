require "rack"
require 'compass_twitter_bootstrap'

require './app'
run App.new

# use Rack::Static, 
#   :urls => ["/css", "/js","/images"],
#   :root => "examples"

#   map "/" do
#     run lambda { |env|
#       [
#         200, 
#         {
#           'Content-Type'  => 'text/html', 
#           'Cache-Control' => 'public, max-age=86400' 
#         },
#         File.open('examples/index.html', File::RDONLY)
#       ]
#     }
#   end

#   map "/styleguide" do
#     run lambda { |env|
#       [
#         200, 
#         {
#           'Content-Type'  => 'text/html', 
#           'Cache-Control' => 'public, max-age=86400' 
#         },
#         File.open('examples/styleguide/index.html', File::RDONLY)
#       ]
#     }
#   end

#   map "/styleguide/tables.html" do
#     run lambda { |env|
#       [
#         200, 
#         {
#           'Content-Type'  => 'text/html', 
#           'Cache-Control' => 'public, max-age=86400' 
#         },
#         File.open('examples/styleguide/tables.html', File::RDONLY)
#       ]
#     }
#   end