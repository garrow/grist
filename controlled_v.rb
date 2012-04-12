require "rubygems"
require "bundler/setup"

require "sinatra/base"
require 'cgi'
require 'pp'

require_relative 'grist'

class ControlledV < Sinatra::Base

  def initialize
    @grist = Grist.new '/Users/garrow/Dropbox/work/controlledv/rep/'
    super
  end

  def link_to_object hash
    "<a href='/view/#{hash}'>#{hash}</a>" if hash
  end

  def display_content hash
    @grist.display_content hash
  end

  def save content, branch = nil, filename = nil
    @grist.save content, branch, filename
  end

  def display_form(content = '', branch = nil )
    content = content.to_s
    action = '/save'
    tpl = "<form method='post' action='%s'><input type='hidden' name='ref' value='%s'><textarea rows='20' cols='120'name='content'>%s</textarea><input type='submit' value='save'/></form>"
    tpl % [ action, branch , CGI.escapeHTML(content) ]
  end

  def escape string
    CGI.escapeHTML(string)
  end

  get '/log' do
    "<pre>#{escape log}</pre>"
  end

  post '/save' do
    hash = save(params[:content], params[:ref])
    link_to_object hash
  end



  post '/paste' do
    u = %x[cd rep/ && echo '#{params[:content]}' | git hash-object -w --stdin]
    "<a href='/view/#{u}'>#{u}</a>"
  end

  #get '/commits/:branch' do
  #  display_form2 display_content(params[:branch]), params[:branch]
  #end
  #
  #get '/view2/:hash' do
  #  display_form display_content(params[:hash])
  #end
  #
  get '/view/:hash' do
    display_form %x[cd rep/ && git cat-file -p #{params[:hash]}]
  end
  #
  #post '/view/:hash' do
  #  u = %x[cd rep/ && echo '#{params[:content]}' | git hash-object -w --stdin]
  #  "<a href='/view/#{u}'>#{u}</a>"
  #end

  get '/' do
    display_form
  end
end