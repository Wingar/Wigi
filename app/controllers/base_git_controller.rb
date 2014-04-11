class BaseGitController < ActionController::Base

  def repo_dir
    Rails.root.to_s + APP_CONFIG[Rails.env]["PAGES_PATH"]
  end

  def repo
    @repo ||= Rugged::Repository.new(repo_dir)
  end

  def all_pages
    head = repo.lookup(repo.head.target)
    YAML.load find_file("pages.yml")
  end

  def find_file(file, commit = repo.lookup(repo.head.target)) # I love how horrible this is
    oid = commit.tree.find { |object| object[:name] == file }[:oid]

    repo.read(oid).data
  end

  def find_page(page)
    object = []
    pages = all_pages
    pages["pages"].each do |entry|
      if entry[0] == page
        object = [entry[0], entry[1]["title"], entry[1]["file"]]
        break
      end
    end
    object
  end
  def stage_file(index, file, file_oid, new_file = false)
    unless new_file
      index.remove(file)
    end
    options = {}
    options[:path] = file
    options[:oid] = file_oid
    options[:mode] = 33188

    index.add(options)
    index
  end

  def new_page(title, contents) # This is too fuckin messy
    index = repo.index
    pages = all_pages
    filtered_title = title.gsub(/[^0-9A-Za-z(\s)]/, '').tr(' ', '_').downcase
    pages["pages"][filtered_title] = {"title" => title, "file" => filtered_title }

    pages_oid = repo.write(pages.to_yaml, :blob)
    index = stage_file(index, "pages.yml", pages_oid)

    new_page_oid = repo.write(contents, :blob)
    index = stage_file(index, filtered_title, new_page_oid, true)

    tree_oid = index.write_tree repo
    index.write

    options = {}
    options[:author] = { :email => "wingar@team-metro.net", :name => "#{request.remote_ip}/#{request.user_agent}", :time => Time.now }
    options[:committer] = options[:author]
    options[:message] ||= "Added page #{title}"
    options[:parents] = [repo.head.target]
    options[:tree] = tree_oid
    options[:update_ref] = 'HEAD'

    Rugged::Commit.create(repo, options)
  end

  def update_file(file, contents)
    index = repo.index
    file_oid = repo.write(contents, :blob)

    index = stage_file(index, file, file_oid)

    tree_oid = index.write_tree repo
    index.write

    options = {}
    options[:author] = { :email => "wingar@team-metro.net", :name => "#{request.remote_ip}/#{request.user_agent}", :time => Time.now }
    options[:committer] = options[:author]
    options[:message] ||= "Updated #{file}"
    options[:parents] = [repo.head.target]
    options[:tree] = tree_oid
    options[:update_ref] = 'HEAD'

    Rugged::Commit.create(repo, options)
  end

  def delete_page(page)
    pages = all_pages
    file = pages["pages"][page]["file"]
    pages["pages"].delete(page)


    index = repo.index

    pages_oid = repo.write(pages.to_yaml, :blob)
    index = stage_file(index, "pages.yml", pages_oid)

    index.remove(file)
    tree_oid = index.write_tree repo
    index.write

    options = {}
    options[:author] = { :email => "wingar@team-metro.net", :name => "#{request.remote_ip}/#{request.user_agent}", :time => Time.now }
    options[:committer] = options[:author]
    options[:message] ||= "Deleted #{file}"
    options[:parents] = [repo.head.target]
    options[:tree] = tree_oid
    options[:update_ref] = 'HEAD'

    Rugged::Commit.create(repo, options)
  end
end
