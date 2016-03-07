# encoding: utf-8
require 'cgi'
require 'sinatra'
require 'sinatra/config_file'
require 'json'
require './lib/slack_api'
require './lib/base_event_handler'

SLACK_API_KEY    = ENV['SLACK_API_KEY']
GITHUB_API_KEY   = ENV['GITHUB_API_KEY']
config_file './config.yml'

$stdout.sync = true

get '/' do
end

post '/payload' do
  data = JSON.parse(request.body.read)
  repository_name = data['repository']['name']
  channel_id = settings.channel_map[repository_name]
  slack = SlackApi.new(SLACK_API_KEY)

  handler = GithubEventHandler.build(data)
  if handler && channel_id
    channel_id = settings.channel_map[handler.repository_name]
    handler.execute(slack, channel_id)
    handler.random(slack, channel_id)
  end
end
