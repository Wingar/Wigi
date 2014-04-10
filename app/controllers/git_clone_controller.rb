class GitCloneController < ApplicationController
  def refs
    render body: invoke_git("for-each-ref", "--format", "%(objectname)\t%(refname)")
  end

  def head
    render body: "ref: #{repo.head.name}"
  end

  def packs
    render body: Dir["#{repo_dir}/objects/pack/pack-*.pack"].map { |packfile|
      "P #{packfile.split("/").last}\n"
    }.join
  end

  def pack_file
    unless params[:file] =~ /\Apack-[0-9a-f]{40}\.(idx|pack)\z/
      return render status: :not_found
    end

    render body: File.read("#{repo_dir}/objects/pack/#{params[:file]}")
  end

  def object
    unless params[:name] =~ %r{\A[0-9a-f]{2}/[0-9a-f]{38}\z}
      return render status: :not_found
    end

    render body: File.read("#{repo_dir}/objects/#{params[:name]}")
  end

private
  def invoke_git(*args)
    IO.popen([{ "GIT_DIR" => repo_dir }, "git", *args], "rb").read
  end
end
