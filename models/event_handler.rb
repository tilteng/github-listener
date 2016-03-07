require_relative './event_handlers/comment_added_event_handler'
require_relative './event_handlers/pull_request_labeled_event_handler'

module EventHandler
  def self.build(data)
    case data['action']
    when 'labeled'
      PullRequestLabeledEventHandler.new(data)
    when 'created'
      CommentAddedEventHandler.new(data)
    end
  end
end
