# encoding: utf-8

require 'cgi'
require 'redis'
require 'sinatra'
require 'json'
require 'github_api'
require "./lib/slack_api"
require "./lib/github_event_handler"

SLACK_API_KEY    = ENV['SLACK_API_KEY']
SLACK_CHANNEL_ID = ENV['SLACK_CHANNEL_ID']
GITHUB_API_KEY   = ENV['GITHUB_API_KEY']
REDISCLOUD_URL   = ENV['REDISCLOUD_URL']

$stdout.sync = true


# TODO: Move these to YAML or ENV
TITLES   = [ '☹₀', '♙₁', '♘₂', '♗₃', '♖₄', '♕₅', '♔₆', '☃₇', '☼₈', '⚛₉', '☯₁₀', '⌘₁₁', '⍟₁₂', '⌹₁₃', '⍰₁₄', '⏏₁₅', '▜₁₆', '☆₁₇', '☕₁₈', '☢₁₉', '☘₂₀' ]
EXPBAR   = [ '▁', '▂', '▃', '▅', '▆', '▇', '█' ]
FACTOR   = 100
INTERVAL = FACTOR.to_f / EXPBAR.size.to_f

get '/' do
end

def increment_user(redis, user, amount)
  redis.set(user.login, (redis.get(user.login).to_i + amount))
end

def exp_icon(score)
  return '' if score <= 0
  return EXPBAR[ ((score % FACTOR) / INTERVAL).to_i ]
end

def score_icon(score)
  return '☠'           if score <= 0
  return ':godmode:₉₉' if score >= (TITLES.size * FACTOR)
  return TITLES[ score / FACTOR ]
end

def review_label!(repository, issue)
  github = Github.new oauth_token: GITHUB_API_KEY
  github.issues.labels.add(repository.organization, repository.name, issue.number, 'Needs Review')
end

def comment_created_message(redis, repository, issue, comment)
  if comment.matches?(/\bp(i|o)ng\b/i)
    message = "Ping :ping:"
    increment_user(redis, comment.user, 1) unless issue.owner?(comment.user)
  elsif comment.matches?(/rebase/i)
    message = "Rebase :git:"
    increment_user(redis, comment.user, 1) unless issue.owner?(comment.user)
  elsif comment.matches?(/\+1/i)
    message = "Thumbs up :+1:"
    increment_user(redis, comment.user, 1)
    increment_user(redis, issue.user, 1)
  elsif comment.matches?(/lgtm/i)
    message = "Looks good :check:"
    increment_user(redis, comment.user, 1) unless issue.owner?(comment.user)
  elsif comment.matches?(/discuss/i)
    message = "Please discuss :muscle:"
    increment_user(redis, comment.user, 2)
  else
    increment_user(redis, comment.user, 1) unless issue.owner?(comment.user)
  end

  score = redis.get(comment.user.login).to_i
  display = exp_icon(score) + score_icon(score)

  if message
    return "[#{repository} #{issue}] #{display} #{comment.user}: #{message}\n>>>#{comment.body.slice(0...255)}"
  end
end

def pull_request_opened_message(redis, repository, pull_request)
  score = redis.get(pull_request.user.login).to_i
  display = exp_icon(score) + score_icon(score)
  increment_user(redis, pull_request.user, 5)

  message = 'Created a pull request :parrot:'
  return "[#{repository} #{pull_request}] #{display} #{pull_request.user}: #{message}"
end

post '/payload' do
  data  = JSON.parse(request.body.read)
  event = GithubEventHandler.new(data)
  redis = Redis.new(:url => REDISCLOUD_URL)
  slack = SlackApi.new(SLACK_API_KEY)
  if event.pull_request?
    if event.opened?
      message = pull_request_opened_message(redis, event.repository, event.pull_request)
      unless message.nil?
        slack.post_message(SLACK_CHANNEL_ID, message)
      end
    end
  elsif event.comment_created?
    if event.issue?
      message = comment_created_message(redis, event.repository, event.issue, event.comment)
      unless message.nil?
        slack.post_message(SLACK_CHANNEL_ID, message)
      end
    else
      increment_user(redis, event.comment.user, 1)
    end
  end
  nil
end

post '/coverage' do
  nil
end
