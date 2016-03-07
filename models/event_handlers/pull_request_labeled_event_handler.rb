require_relative './base_event_handler'

class PullRequestLabeledEventHandler < BaseEventHandler
  def execute!(slack, slack_room_id)
    if label == 'Needs review'
      slack.post_message(slack_room_id, "[#{repository_link} #{pull_request_link}] #{target_user_login}: Needs review :git:>>>#{title}")
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
