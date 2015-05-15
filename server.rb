require 'sinatra'
require 'json'
require "./lib/slack_api"
require "./lib/github_event_handler"

SLACK_API_KEY = ENV['SLACK_API_KEY']
SLACK_CHANNEL_ID = ENV['SLACK_CHANNEL_ID']

get '/' do
end

def comment_created_message(issue, comment)
  if comment.matches?(/p\w\wg/i)
    if issue.owner?(comment.user)
      "#{comment.user} wants input on their issue #{issue}\n```#{comment.body}```"
    else
      "#{comment.user} finished reviewing the issue and wants some comments #{issue}\n```#{comment.body}```"
    end
  elsif comment.matches?(/lgtm/i)
    if issue.owner?(comment.user)
      "#{comment.user} thinks their issue is great #{issue}\n```#{comment.body}```"
    else
      "#{comment.user} finished reviewing #{issue}\n```#{comment.body}```"
    end
  elsif comment.matches?(/test/i)
    "#{comment.user} wants to see the tests on #{issue}\n```#{comment.body}```"
  end
end

post '/payload' do
  data = JSON.parse(request.body.read)
  event = GithubEventHandler.new(data)
  issue = event.issue
  comment = event.comment
  if event.comment_created?
    message = comment_created_message(issue, comment)
    unless message.nil?
      slack = SlackIntegration.new(SLACK_API_KEY)
      slack.post_message(SLACK_CHANNEL_ID, message)
    end
  end
  nil
end
