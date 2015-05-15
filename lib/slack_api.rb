require 'httparty'
require 'json'

class SlackApi
  def initialize(api_key)
    @api_key = api_key
  end

  def list_channels
    url = "https://slack.com/api/channels.list"
    self.post(url)["channels"]
  end

  def post_message(channel_id, message, options={})
    url = "https://slack.com/api/chat.postMessage"
    self.post(url, {
      channel: channel_id,
      as_user: true,
      text: message
    }.merge(options))
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

