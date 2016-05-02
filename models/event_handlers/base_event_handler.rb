class BaseEventHandler
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

  def target_user_login
    @data['pull_request']['user']['login']
  end
end
