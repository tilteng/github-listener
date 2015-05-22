require 'sinatra'
require 'json'
require 'github_api'
require "./lib/slack_api"
require "./lib/github_event_handler"

SLACK_API_KEY    = ENV['SLACK_API_KEY']
SLACK_CHANNEL_ID = ENV['SLACK_CHANNEL_ID']
GITHUB_API_KEY   = ENV['GITHUB_API_KEY']

get '/' do
end

def review_label!(repository, issue)
  github = Github.new oauth_token: GITHUB_API_KEY
  github.issues.labels.add(repository.organization, repository.name, issue.number, 'Needs Review')
end

def comment_created_message(repository, issue, comment)
  if comment.matches?(/p\w\wg/i)
    message = "Ping :ping:"
  elsif comment.matches?(/\+1/i)
    message = "Thumbs up :+1:"
  elsif comment.matches?(/lgtm/i)
    message = "Looks good :check:"
  end

  if message
    return "[#{repository} #{issue}] #{comment.user}: #{message}\n>>>#{comment.body.slice(0...100)}..."
  end
end

post '/payload' do
  data = JSON.parse(request.body.read)
  event = GithubEventHandler.new(data)
  issue = event.issue
  comment = event.comment
  if event.comment_created?
    message = comment_created_message(event.repository, issue, comment)
    unless message.nil?
      slack = SlackApi.new(SLACK_API_KEY)
      slack.post_message(SLACK_CHANNEL_ID, message)
    end
  end
  nil
end
