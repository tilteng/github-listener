require_relative './base_event_handler'
require './lib/user_experience'

class CommentAddedEventHandler < BaseEventHandler
  def target_user_login
    @data['comment']['user']['login']
  end

  def execute!(redis)
    user = UserExperience::User.new(redis, target_user_login)
    user.increment
    if comment_body =~ /\bp(i|o)ng\b/i
      return message(user, 'ping')
    elsif comment_body =~ /\+1/i
      return message(user, '+1')
    elsif comment_body =~ /\+\+/i
      return message(user, '++')
    elsif comment_body =~ /lgtm/i
      return message(user, 'looks good')
    elsif comment_body =~ /discuss/i
      return message(user, 'discuss :muscle:')
    end
  end

private

  def message(user, label)
    "[#{repository_link} #{comment_link}] #{user.display}: #{label}\n>>>#{comment_preview}"
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
