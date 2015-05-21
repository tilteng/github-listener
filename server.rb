require 'sinatra'
require 'json'
require 'github_api'
require "./lib/slack_api"
require "./lib/github_event_handler"

SLACK_API_KEY = ENV['SLACK_API_KEY']
SLACK_CHANNEL_ID = ENV['SLACK_CHANNEL_ID']

GITHUB_API_KEY = ENV['GITHUB_API_KEY']

def team_name_for_project(repository)
  "[review:#{repository.name}]"
end

get '/' do
end

def review_label!(repository, issue)
  github = Github.new oauth_token: GITHUB_API_KEY
  github.issues.labels.add(repository.organization, repository.name, issue.number, 'Needs Review')
end

def comment_created_message(repository, issue, comment)
  if comment.matches?(/p\w\wg/i)
    if issue.owner?(comment.user)
      message = "wants input on their issue"
    else
      message = "wants input on this issue"
    end
  elsif comment.matches?(/\+1/i)
    if issue.owner?(comment.user)
      message = "gave themselves a thumbs up"
    else
      message = "thumbs up!"
    end
  elsif comment.matches?(/lgtm/i)
    if issue.owner?(comment.user)
      message = "thinks their issue is great"
    else
      message = "has a positive opinion about this"
    end
  end

  if message
    return "#{team_name_for_project(repository)}#{issue} #{comment.user} #{message}\n```#{comment.body.slice(0...100)}```"
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
