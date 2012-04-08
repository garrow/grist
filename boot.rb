require "rubygems"
require "bundler/setup"

require "sinatra"
require 'cgi'
require 'pp'
def link_to_commit hash
  "<a href='/commits/#{hash}'>#{hash}</a>"
end




def save content, branch = nil,  filename = 'temp.txt'

  if branch && branch.empty? 
      branch = nil
  end

  blob_hash    = %x[cd rep/ && echo '#{content}' | git hash-object -w --stdin]  
  blob_hash.chomp!

  pp "BLOB-HASH"
  pp blob_hash
#  tree         = "10644 #{blob_hash} #{filename}"
  update_index = %x[cd rep/ && git update-index --add --cacheinfo 100644 #{blob_hash} #{filename} ]
  pp "UPDATE INDEX"
  tree_hash    = %x[cd rep/ &&  git write-tree ]
  pp "TREE-HASH" << tree_hash

  #abbrev_hash = commit_hash.slice 0,7
if branch and !branch.empty?
    pp 'GOT-BRANCH'
    pp branch
  p_commit_hash = %x[ cd rep/ && git show-ref --heads --hash #{branch}] 
  p_commit_hash.chomp! 
  pre = " -p #{p_commit_hash}" 
else
  pre = ''
end


  
  commit_hash  = %x[cd rep/ &&  echo 'Writing tree as commit -- ' | git commit-tree #{tree_hash} #{pre} ]
 pp 'COMMIT_HASH' << commit_hash 
 branch ||= commit_hash.slice 0,7
  #prev_branch = branch ? "-p #{branch}" : ''
 #
pp 'BRANCH ' << branch 

#  update_ref   = %x[cd rep/ &&  git update-ref refs/heads/master #{commit_hash} ]
  update_ref   = %x[cd rep/ &&  git update-ref refs/heads/#{branch} #{commit_hash} ]
#git update-ref refs/heads/0eac1cf5a890119d0c93a4b4f4d3069887fa767f 0eac1cf5a890119d0c93a4b4f4d3069887fa767f

  branch
end

def load branch_hash
#  commit = 

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
def log
    %x[cd rep/ &&  git log ]
end

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

def load_branch_tip branch
  
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

