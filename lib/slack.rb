require 'httparty'
require 'json'

module Slack
  class Connection
    def initialize(api_key)
      @api_key = api_key
    end

    def channels
      url = "https://slack.com/api/channels.list"
      self.post(url)["channels"]
    end

    def channel(channel_id)
      if channel_id.nil?
        nil
      else
        Channel.new(self, channel_id)
      end
    end

    def post(url, body={})
      response = HTTParty.post(url, {
        body: {
          token: @api_key
        }.merge(body)
      })
      JSON.parse(response.body)
    end
  end

  class Channel
    def initialize(connection, channel_id)
      @connection = connection
      @channel_id = channel_id
    end

    def message(message, options={})
      @connection.post("https://slack.com/api/chat.postMessage", {
        channel: @channel_id,
        as_user: true,
        text: message
      }.merge(options))
    end
  end
end
