require_relative './event_handlers/comment_added_event_handler'
require_relative './event_handlers/pull_request_labeled_event_handler'
require_relative './event_handlers/review_submitted_handler'

module EventHandler
  def self.build(data)
    case data['action']
    when 'labeled'
      puts "Handling labeled event"
      PullRequestLabeledEventHandler.new(data)
    when 'created'
      if data['comment']
        puts "Handling comment created event"
        CommentAddedEventHandler.new(data)
      end
    when 'submitted'
      if data['review']
        puts "Handling review submitted event"
        ReviewSubmittedHandler.new(data)
      end
    end
  end
end
