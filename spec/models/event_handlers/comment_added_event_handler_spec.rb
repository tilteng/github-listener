require_relative "../../../models/event_handlers/comment_added_event_handler"

def generate_comment_payload(body)
  {
    "comment" => {
      "user" => {
        "login" => "baxterthehacker",
        "html_url" => "https://github.com/baxterthehacker",
      },
      "body" => body,
      "html_url" => "https://github.com/baxterthehacker/public-repo/pull/1#discussion_r29724692",
    },
    'repository' => {
      'name' => 'public-repo',
      'full_name' =>  'baxterthehacker/public-repo',
      "html_url" => "https://github.com/baxterthehacker/public-repo",
    },
    'pull_request' => {
      'html_url' => 'https://github.com/baxterthehacker/public-repo/pull/1',
      'number' => 10,
      'title' => 'An important pull request',
      'user' => {
        'login' => 'baxterthehacker'
      }
    },
  }
end

describe CommentAddedEventHandler do
  describe '#execute' do
    it 'does nothing for an arbitrary comment' do
      slack = double(:slack)
      channel = 'cool channel'

      handler = CommentAddedEventHandler.new(generate_comment_payload("Maybe you should use more emojji on this line."))
      expect(handler.execute!(slack, channel)).to eq(nil)
    end

    it 'sends a message when comment body includes "discuss"' do
      slack = double(:slack)
      allow(slack).to receive(:post_message!) { |channel_id, message| message }
      expect(slack).to receive(:post_message).with('#cool-channel', "[<http://github.com/baxterthehacker/public-repo|review:public-repo> <https://github.com/baxterthehacker/public-repo/pull/1#discussion_r29724692|#10>] baxterthehacker: discuss :muscle:\n>>>Maybe you should use more emojji on this line. discuss.")

      handler = CommentAddedEventHandler.new(generate_comment_payload("Maybe you should use more emojji on this line. discuss."))
      handler.execute!(slack, '#cool-channel')
    end

    it 'sends a message when comment body includes "lgtm"' do
      slack = double(:slack)
      allow(slack).to receive(:post_message!) { |channel_id, message| message }
      expect(slack).to receive(:post_message).with('#cool-channel', "[<http://github.com/baxterthehacker/public-repo|review:public-repo> <https://github.com/baxterthehacker/public-repo/pull/1#discussion_r29724692|#10>] baxterthehacker: looks good\n>>>this pr lgtm.")

      handler = CommentAddedEventHandler.new(generate_comment_payload('this pr lgtm.'))
      handler.execute!(slack, '#cool-channel')
    end

    it 'sends a message when comment body includes "ping"' do
      slack = double(:slack)
      allow(slack).to receive(:post_message!) { |channel_id, message| message }
      expect(slack).to receive(:post_message).with('#cool-channel', "[<http://github.com/baxterthehacker/public-repo|review:public-repo> <https://github.com/baxterthehacker/public-repo/pull/1#discussion_r29724692|#10>] baxterthehacker: ping\n>>>i like to play ping pong")

      handler = CommentAddedEventHandler.new(generate_comment_payload('i like to play ping pong'))
      handler.execute!(slack, '#cool-channel')
    end

    it 'sends a message when comment body includes "+1"' do
      slack = double(:slack)
      allow(slack).to receive(:post_message!) { |channel_id, message| message }
      expect(slack).to receive(:post_message).with('#cool-channel', "[<http://github.com/baxterthehacker/public-repo|review:public-repo> <https://github.com/baxterthehacker/public-repo/pull/1#discussion_r29724692|#10>] baxterthehacker: +1\n>>>+1 this is a great idea.")

      handler = CommentAddedEventHandler.new(generate_comment_payload('+1 this is a great idea.'))
      handler.execute!(slack, '#cool-channel')
    end

    it 'sends a message when comment body includes "++"' do
      slack = double(:slack)
      allow(slack).to receive(:post_message!) { |channel_id, message| message }
      expect(slack).to receive(:post_message).with('#cool-channel', "[<http://github.com/baxterthehacker/public-repo|review:public-repo> <https://github.com/baxterthehacker/public-repo/pull/1#discussion_r29724692|#10>] baxterthehacker: ++\n>>>++ hero!")

      handler = CommentAddedEventHandler.new(generate_comment_payload('++ hero!'))
      handler.execute!(slack, '#cool-channel')
    end

  end
end
