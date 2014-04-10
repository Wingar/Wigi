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
    return render_404 unless params[:file] =~ /\Apack-[0-9a-f]{40}\.(idx|pack)\z/

    render body: File.read("#{repo_dir}/objects/pack/#{params[:file]}")
  rescue Errno::ENOENT
    render_404
  end

  def object
    return render_404 unless params[:name] =~ %r{\A[0-9a-f]{2}/[0-9a-f]{38}\z}

    render body: File.read("#{repo_dir}/objects/#{params[:name]}")
  rescue Errno::ENOENT
    render_404
  end

private
  def render_404
    render status: :not_found, nothing: true
  end

  def invoke_git(*args)
    IO.popen([{ "GIT_DIR" => repo_dir }, "git", *args], "rb").read
  end
end
