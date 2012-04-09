require "rubygems"
require "bundler/setup"

require "sinatra"
require 'cgi'
require 'pp'

def link_to_commit hash
  "<a href='/commits/#{hash}'>#{hash}</a>"
end



def display_form(content = nil)
  action = content ? '/paste' : '/update'
  tpl = "<form method='post' action='%s'><textarea rows='50' cols='120'name='content'>%s</textarea><input type='submit' value='save'/></form>"
  #{}<

 tpl % [ action, CGI.escapeHTML(content) ]
end

def display_form2(content = nil, branch = nil )
  action = '/save'
  tpl = "<form method='post' action='%s'><input type='hidden' name='ref' value='%s'><textarea rows='20' cols='120'name='content'>%s</textarea><input type='submit' value='save'/></form>"

 tpl % [ action, branch , CGI.escapeHTML(content) ]
end  

def display_content hash
  %x[cd rep/ && git cat-file -p #{hash}]
end
#
#get '/view/:hash' do
#  %x[cd rep/ && git cat-file -p #{params[:hash]}]
#end


def escape string
  CGI.escapeHTML(string)
end

get '/log' do
  "<pre>#{escape log}</pre>"
end

post '/save' do 
    hash = save(params[:content], params[:ref])

    link_to_commit hash
end


post '/paste' do 
  u = %x[cd rep/ && echo '#{params[:content]}' | git hash-object -w --stdin]   
  "<a href='/view/#{u}'>#{u}</a>"
end



get '/commits/:branch' do
    display_form2 display_content(params[:branch]), params[:branch]
end


get '/view/:hash' do
  display_form %x[cd rep/ && git cat-file -p #{params[:hash]}]
end

post '/view/:hash' do
  u = %x[cd rep/ && echo '#{params[:content]}' | git hash-object -w --stdin]   
  "<a href='/view/#{u}'>#{u}</a>"
end

get '/' do
    display_form2 ''
end

