require 'grit'

module Grit
  self.debug = true
end

class Grist
  def initialize repo_path
    @repo = build_repo repo_path
  end

  def build_repo repo_path
    Grit::Repo.new repo_path
  end
  private :build_repo

  def repo
    @repo
  end

  def display_content hash
    repo.blob(hash).data
    #%x[cd rep/ && git cat-file -p #{hash}]
  end



  def save content, branch = nil, filename = 'temp.txt'
    if branch && branch.empty?
      branch = nil
    end

    filename = 'temp.txt' if filename.to_s.empty?

    blob_hash = repo.git.put_raw_object content, 'blob'

    #pp "BLOB-HASH #{blob_hash}"

#  tree         = "10644 #{blob_hash} #{filename}"
#    cmd = "git update-index --add --cacheinfo 100644 #{blob_hash} #{filename} ]"
    repo.git.native :update_index,  {}, '--add', '--cacheinfo' ,  '10644', blob_hash, filename
    tree_hash = repo.git.native :write_tree
    #tree_hash    = %x[cd rep/ && git write-tree ]
    #pp "TREE-HASH #{tree_hash}"

    #abbrev_hash = commit_hash.slice 0,7
    if branch and !branch.empty?
      #pp 'GOT-BRANCH'
      #pp branch
      #TODO get all prev commits, convert to Grit
      p_commit_hash = %x[ cd rep/ && git show-ref --heads --hash #{branch}]
      p_commit_hash.chomp!
      pre = " -p #{p_commit_hash}"
    else
      pre = ''
    end

    #commit_hash = repo.commit_index 'Writing tree as commit :: FOO'
    #commit_hash = repo.commit_objects
    #commit_hash  = %x[cd rep/ &&  echo 'Writing tree as commit -- ' | git commit-tree #{tree_hash} #{pre} ]
    commit_hash = repo.git.native :commit_tree, {}, tree_hash, pre


    branch ||= commit_hash.slice 0,7
    #prev_branch = branch ? "-p #{branch}" : ''
    #
#  update_ref   = %x[cd rep/ &&  git update-ref refs/heads/master #{commit_hash} ]
#    update_ref   = %x[cd rep/ &&  git update-ref refs/heads/#{branch} #{commit_hash} ]
    update_ref = repo.git.native :update_ref,  {}, "refs/heads/#{branch}", commit_hash

#git update-ref refs/heads/0eac1cf5a890119d0c93a4b4f4d3069887fa767f 0eac1cf5a890119d0c93a4b4f4d3069887fa767f

    branch
  end

  def log
    %x[cd rep/ &&  git log ]
  end


end


def gexec command
  return `pwd`
end


def load_branch_tip branch

end








def load branch_hash
#  commit =

end
