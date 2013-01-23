require 'rubygems' 
require 'sinatra'
require 'sinatra/base'
require 'kss'
require 'erb'

class App < Sinatra::Base
  get '/' do
    @nav = "main"
    erb :index
  end

  get '/styleguide' do
    @styleguide = Kss::Parser.new('src/scss/')
    erb :"styleguide/one", layout: :styleguide_layout
  end

  get '/styleguide/columns' do
    @styleguide = Kss::Parser.new('src/scss/')
    erb :"styleguide/two", layout: :styleguide_layout
  end

  get '/styleguide/rows' do
    @styleguide = Kss::Parser.new('src/scss/')
    erb :"styleguide/three", layout: :styleguide_layout
  end

  get '/styleguide/cells' do
    @styleguide = Kss::Parser.new('src/scss/')
    erb :"styleguide/four", layout: :styleguide_layout
  end

  helpers do
    # Generates a styleguide block. A little bit evil with @_out_buf, but
    # if you're using something like Rails, you can write a much cleaner helper
    # very easily.
    def styleguide_block(section, &block)
      @section = @styleguide.section(section)
      @example_html = capture{ block.call }
      @escaped_html = ERB::Util.html_escape @example_html
      @_out_buf << erb(:_styleguide_block)
    end

    # Captures the result of a block within an erb template without spitting it
    # to the output buffer.
    def capture(&block)
      out, @_out_buf = @_out_buf, ""
      yield
      @_out_buf
    ensure
      @_out_buf = out
    end
  end
end