require "json"

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
    "@#{login}"
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

class GithubEventHandler
  def initialize(event)
    @event = event
  end

  def comment_created?
    @event["action"] == "created"
  end

  def comment?
    !@event["comment"].nil?
  end

  def issue
    GithubIssue.new(@event["issue"])
  end

  def comment
    GithubComment.new(@event["comment"])
  end
end
