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

post '/messages' do
  EMOJI = %w[
    :parrot: :pacman: :pig: :octopus: :chicken: :crickets: :bee: :bird:
    :crocodile: :ghost2: :rooster: :best: :turkey: :corgi: :doge:
  ]
  event = rand(10)
  random_emoji = EMOJI[rand(EMOJI.size)]
  target_user_login = params[:text].gsub(params[:trigger_word], '').strip

  case params[:trigger_word]
  when 'battle'
    content_type :json
    {
      :text => "#{target_user_login}. A wild #{random_emoji} appears. But it got away..."
    }.to_json
  end
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

get '/user/:user_id' do
  redis = Redis.new(:url => REDISCLOUD_URL)
  login = params['user_id']
  captures = redis.lrange("#{login}_pets", 0, 10).join(' ')
  "#{login}'s collection #{captures}"
end
