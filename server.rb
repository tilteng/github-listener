# encoding: utf-8
require 'cgi'
require 'sinatra'
require 'sinatra/config_file'
require 'redis'
require 'json'
require './lib/slack'
require './models/event_handler'
require './models/emoji'

REDISCLOUD_URL   = ENV['REDISCLOUD_URL']
SLACK_API_KEY    = ENV['SLACK_API_KEY']

config_file './config.yml'
$stdout.sync = true

get '/' do
end

post '/messages' do
  message = params[:text].gsub(params[:trigger_word], '').strip
  case params[:trigger_word]
  when 'battle'
    redis = Redis.new(:url => REDISCLOUD_URL)
    redis.lpush("beer", message)

    content_type :json
    { :text => 'Whatever you say!' }.to_json
  end
end

def slack_channel_name(data)
  repo_name = data['repository']['name']
  settings.channel_map[repo_name]
end

post '/payload' do
  data = JSON.parse(request.body.read)
  channel_name = slack_channel_name(data)
  channel = Slack::Connection.new(SLACK_API_KEY).channel(channel_name)
  redis = Redis.new(:url => REDISCLOUD_URL)
  manager = Emoji::Manager.new(redis)

  handler = EventHandler.build(data)
  if handler && channel
    login = handler.target_user_login
    message = handler.execute!(redis)
    if message
      channel.message message
      encounter = manager.random_encounter(login)
      unless encounter.nil?
        channel.message encounter.format(login)
        channel.message "#{login}'s collection #{manager.server.list(login, 0, 10).join(' ')}"
      end
    end
  end
end

get '/user/:user_id' do
  manager = Emoji::Manager.new(Redis.new(:url => REDISCLOUD_URL))
  login = params['user_id']

  captures = manager.server.list(login, 0, 10).join(' ')
  "#{login}'s collection #{captures}"
end
