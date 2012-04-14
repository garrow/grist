require 'grit'

module Grit
  self.debug = true
end

class Grist
  def initialize repo_path
    @repo = Grit::Repo.new repo_path
  end

  def repo
    @repo
  end

  def get_content hash
    repo.blob(hash).data
  end

  def save content, branch = nil, filename = 'temp.txt'
    if branch && branch.empty?
      branch = nil
    end

    filename = 'temp.txt' if filename.to_s.empty?

    blob_hash = repo.git.put_raw_object content, 'blob'

    repo.git.native :update_index,  {}, '--add', '--cacheinfo' ,  '10644', blob_hash, filename

    tree_hash = repo.git.native :write_tree
    if branch and !branch.empty?
      #TODO get all prev commits
      p_commit_hash = repo.git.native :show_ref, {}, '--heads', '--hash', branch
      #p_commit_hash = %x[ cd rep/ && git show-ref --heads --hash #{branch}]
      p_commit_hash.chomp!
      previous_commits = " -p #{p_commit_hash}"
    else
      previous_commits = ''
    end

    commit_hash = repo.git.native :commit_tree, {}, tree_hash, previous_commits

    branch ||= commit_hash.slice 0,7
    update_ref = repo.git.native :update_ref,  {}, "refs/heads/#{branch}", commit_hash
    branch
  end

  def log
    %x[cd rep/ &&  git log ]
  end

end
