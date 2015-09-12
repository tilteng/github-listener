require 'httparty'
require "json"

class GithubRepository
  def initialize(hash)
    @data = hash
  end

  def organization
    @data["full_name"].split("/")[0]
  end

  def name
    @data["name"]
  end

  def to_s
    to_slack_string
  end

  def to_slack_string
    "<http://github.com/#{@data["full_name"]}|review:#{@data["name"]}>"
  end
end

class GithubComment
  def initialize(comment)
    @comment = comment
  end

  def url
    @comment["html_url"]
  end

  def body
    @comment["body"]
  end

  def user
    GithubUser.new(@comment["user"])
  end

  def matches?(reg)
    reg.match(body)
  end
end

class GithubUser
  def initialize(user)
    @user = user
  end

  def id
    @user["id"]
  end

  def login
    @user["login"]
  end

  def to_s
    to_slack_string
  end

  def to_slack_string
    "<http://github.com/#{login}|#{login}>"
  end
end

class GithubIssue
  def initialize(issue)
    @issue = issue
  end

  def number
    @issue["number"]
  end

  def url
    @issue["html_url"]
  end

  def labels
    @issue["labels"]
  end

  def user
    @user ||= GithubUser.new(@issue['user'])
  end

  def owner?(other)
    self.user.id == other.id
  end

  def to_slack_string
    "<#{url}|##{number}>"
  end

  def to_s
    to_slack_string
  end
end

class GithubPullRequest
  def initialize(data)
    @data = data
  end

  def data
    @data
  end

  def user
    GithubUser.new(@data["user"])
  end

  def url
    @data["html_url"]
  end

  def number
    @data["number"]
  end

  def to_slack_string
    "<#{url}|##{number}>"
  end

  def to_s
    to_slack_string
  end
end

class GithubEventHandler
  def initialize(data)
    @data = data
  end

  def comment_created?
    @data["action"] == "created"
  end

  def comment
    GithubComment.new(@data["comment"])
  end

  def comment?
    !@data["comment"].nil?
  end

  def issue
    GithubIssue.new(@data["issue"])
  end

  def pull_request
    GithubPullRequest.new(@data['pull_request'])
  end

  def labeled?
    @data['action'] === 'labeled' || @data['action'] === 'unlabeled'
  end

  def opened?
    @data["action"] === "opened"
  end

  def pull_request?
    !@data['pull_request'].nil?
  end

  def issue?
    !@data["issue"].nil?
  end

  def repository
    @repository ||= GithubRepository.new(@data['repository'])
  end
end
