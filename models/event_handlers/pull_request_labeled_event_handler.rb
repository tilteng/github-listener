require_relative './base_event_handler'

class PullRequestLabeledEventHandler < BaseEventHandler
  def execute!(redis, slack, slack_room_id)
    if label.downcase == 'needs review'
      slack.post_message(slack_room_id, "[#{repository_link} #{pull_request_link}] #{user_display(redis, target_user_login)}: Needs review\n>>>#{title}")
      self.random!(redis, slack, slack_room_id)
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
