class BaseEventHandler
  def self.build(data)
    case data['action']
    when 'labeled'
      PullRequestLabeledEventHandler.new(data)
    when 'created'
      CommentAddedEventHandler.new(data)
    end
  end

  def initialize(data)
    @data = data
  end

  def repository_link
    full_name = @data['repository']['full_name']
    name = @data['repository']['name']
    "<http://github.com/#{full_name}|review:#{name}>"
  end

  def pull_request_link
    url = @data['pull_request']['html_url']
    number = @data['pull_request']['number']
    "<#{url}|##{number}>"
  end

  def pull_request_user_login
    @data['pull_request']['user']['login']
  end
end
