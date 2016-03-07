require_relative './base_event_handler'

class CommentAddedEventHandler < BaseEventHandler
  def execute!(slack, slack_room_id)
    if comment_body =~ /\bp(i|o)ng\b/i
      slack.post_message slack_room_id, message('ping')
    elsif comment_body =~ /\+1/i
      slack.post_message slack_room_id, message('+1')
    elsif comment_body =~ /lgtm/i
      slack.post_message slack_room_id, message('looks good')
    elsif comment_body =~ /discuss/i
      slack.post_message slack_room_id, message('discuss :muscle:')
    end
  end

  def target_user_login
    @data['comment']['user']['login']
  end

private

  def message(label)
    "[#{repository_link} #{comment_link}] #{target_user_login}: #{label}\n>>>#{comment_preview}"
  end

  def comment_body
    @data['comment'] && @data['comment']['body']
  end

  def comment_preview
    comment_body.slice(0...255)
  end

  def comment_link
    url = @data['comment']['html_url']
    # number = @data['issue']['number']
    "<#{url}|comment>"
  end
end
