class BaseGitController < ActionController::Base

  before_action :repo_initialize

  def repo_initialize
    @repo = Rugged::Repository.new(Rails.root.to_s + APP_CONFIG[Rails.env]["PAGES_PATH"])
  end

  def repo
    @repo
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
        object = [entry[0], entry[1]["file"]]
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
    pages["pages"][title] = {"file" => title}

    pages_oid = repo.write(pages.to_yaml, :blob)
    index = stage_file(index, "pages.yml", pages_oid)

    new_page_oid = repo.write(contents, :blob)
    index = stage_file(index, title, new_page_oid, true)

    tree_oid = index.write_tree repo
    index.write

    options = {}
    options[:author] = { :email => "wingar@team-metro.net", :name => "Admin", :time => Time.now }
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
    options[:author] = { :email => "wingar@team-metro.net", :name => "Admin", :time => Time.now }
    options[:committer] = options[:author]
    options[:message] ||= "Updated #{file}"
    options[:parents] = [repo.head.target]
    options[:tree] = tree_oid
    options[:update_ref] = 'HEAD'

    Rugged::Commit.create(repo, options)
  end
end
