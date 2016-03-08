# encoding: utf-8
require 'cgi'
require 'sinatra'
require 'sinatra/config_file'
require 'redis'
require 'json'
require './lib/slack_api'
require './models/event_handler'

REDISCLOUD_URL   = ENV['REDISCLOUD_URL']
SLACK_API_KEY    = ENV['SLACK_API_KEY']

config_file './config.yml'
$stdout.sync = true

get '/' do
end

post '/payload' do
  data = JSON.parse(request.body.read)
  repository_name = data['repository']['name']
  channel_id = settings.channel_map[repository_name]
  slack = SlackApi.new(SLACK_API_KEY)
  redis = Redis.new(:url => REDISCLOUD_URL)

  handler = EventHandler.build(data)
  if handler && channel_id
    channel_id = settings.channel_map[repository_name]
    handler.execute!(redis, slack, channel_id)
  end
end
