class BaseEventHandler
  EMOJI = %w[:parrot: :pacman: :pig: :octopus: :chicken:]

  def self.build(data)
    case data['action']
    when 'labeled'
      PullRequestLabeledEventHandler.new(data)
    when 'created'
      CommentAddedEventHandler.new(data)
    end
  end

  def random!(slack, channel_id)
    event = rand(10)
    random_emoji = EMOJI[rand(EMOJI.size)]
    if event === 0
      slack.post_message(channel_id, "A wild #{random_emoji} appears.\n#{target_user_login} captured #{random_emoji}")
    elsif event == 1
      slack.post_message(channel_id, "A wild #{random_emoji} appears.\nit got away...")
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

  def target_user_login
    @data['pull_request']['user']['login']
  end
end
