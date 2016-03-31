require_relative './base_event_handler'

class CommentAddedEventHandler < BaseEventHandler
  def execute!(redis, slack, slack_room_id)
    if comment_body =~ /\bp(i|o)ng\b/i
      slack.post_message slack_room_id, message(redis, 'ping')
      self.random!(redis, slack, slack_room_id)
    elsif comment_body =~ /\+1/i
      slack.post_message slack_room_id, message(redis, '+1')
      self.random!(redis, slack, slack_room_id)
    elsif comment_body =~ /\+\+/i
      slack.post_message slack_room_id, message(redis, '++')
      self.random!(redis, slack, slack_room_id)
    elsif comment_body =~ /lgtm/i
      slack.post_message slack_room_id, message(redis, 'looks good')
      self.random!(redis, slack, slack_room_id)
    elsif comment_body =~ /discuss/i
      slack.post_message slack_room_id, message(redis, 'discuss :muscle:')
      self.random!(redis, slack, slack_room_id)
    end
    self.increment_user(redis, target_user_login)
  end

  def target_user_login
    @data['comment']['user']['login']
  end

private

  def message(redis, label)
    "[#{repository_link} #{comment_link}] #{user_display(redis, target_user_login)}: #{label}\n>>>#{comment_preview}"
  end

  def comment_body
    @data['comment'] && @data['comment']['body']
  end

  def comment_preview
    comment_body.slice(0...255)
  end

  def comment_link
    url = @data['comment']['html_url']
    if @data['issue']
      number = @data['issue']['number']
    elsif @data['pull_request']
      number = @data['pull_request']['number']
    else
      number = '???'
    end
    "<#{url}|##{number}>"
  end
end
