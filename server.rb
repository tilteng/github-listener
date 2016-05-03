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
  redis = Redis.new(:url => REDISCLOUD_URL)
  manager = Emoji::Manager.new(redis)

  message = params[:text].gsub(params[:trigger_word], '').strip
  case params[:trigger_word]
  when 'pets:'
    text = "#{message}'s collection #{manager.server.list(message, 0, 10).join(' ')}"
    content_type :json
    { :text => text }.to_json
  when 'beer:'
    if message.length > 0
      redis.lpush('beer_list', message)
    end
    results = redis.lrange('beer_list', 0, 10).map do |message|
      ":beer: #{message}"
    end
    content_type :json
    { :text => results.join("\n") }.to_json
  when 'pay:'
    content_type :json
    { :text => "#{params[:user_name]} gave #{message} a :beer:" }.to_json
  when 'battle:'
    result = manager.battle(message)
    text = result.format(message)
    if result.captured?
      text = "#{text}\n#{message}'s collection #{manager.server.list(message, 0, 10).join(' ')}"
    end

    content_type :json
    { :text => text }.to_json
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
