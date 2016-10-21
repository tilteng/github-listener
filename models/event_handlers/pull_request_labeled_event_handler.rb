require_relative './base_event_handler'
require './lib/user_experience'

class PullRequestLabeledEventHandler < BaseEventHandler
  def execute!(redis)
    if label.downcase == 'needs review'
      user = UserExperience::User.new(redis, target_user_login)
      user.increment
      return "[#{repository_link} #{pull_request_link}] #{user.display}: Needs review\n>>>#{title}"
    end
  end

private

  def label
    @data['label'] && @data['label']['name']
  end

  def title
    @data['pull_request']['title']
  end
end
