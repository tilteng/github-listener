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

    def redis
      redis = double(:redis)
      allow(redis).to receive(:get).with('baxterthehacker') { 500 }
      allow(redis).to receive(:set).with('baxterthehacker', 501)

      redis
    end

    it 'does nothing for an arbitrary comment' do
      channel = 'cool channel'

      handler = CommentAddedEventHandler.new(generate_comment_payload("Maybe you should use more emojji on this line."))
      expect(handler.execute!(redis)).to eq(nil)
    end

    it 'sends a message when comment body includes "discuss"' do
      handler = CommentAddedEventHandler.new(generate_comment_payload("Maybe you should use more emojji on this line. discuss."))
      expect(handler.execute!(redis)).to eq("[<http://github.com/baxterthehacker/public-repo|review:public-repo> <https://github.com/baxterthehacker/public-repo/pull/1#discussion_r29724692|#10>] ▁♕₅ baxterthehacker: discuss :muscle:\n>>>Maybe you should use more emojji on this line. discuss.")
    end

    it 'sends a message when comment body includes "lgtm"' do
      handler = CommentAddedEventHandler.new(generate_comment_payload('this pr lgtm.'))
      expect(handler.execute!(redis)).to eq("[<http://github.com/baxterthehacker/public-repo|review:public-repo> <https://github.com/baxterthehacker/public-repo/pull/1#discussion_r29724692|#10>] ▁♕₅ baxterthehacker: looks good\n>>>this pr lgtm.")
    end

    it 'sends a message when comment body includes "ping"' do
      handler = CommentAddedEventHandler.new(generate_comment_payload('i like to play ping pong'))
      expect(handler.execute!(redis)).to eq("[<http://github.com/baxterthehacker/public-repo|review:public-repo> <https://github.com/baxterthehacker/public-repo/pull/1#discussion_r29724692|#10>] ▁♕₅ baxterthehacker: ping\n>>>i like to play ping pong")
    end

    it 'sends a message when comment body includes "+1"' do
      handler = CommentAddedEventHandler.new(generate_comment_payload('+1 this is a great idea.'))
      expect(handler.execute!(redis)).to eq("[<http://github.com/baxterthehacker/public-repo|review:public-repo> <https://github.com/baxterthehacker/public-repo/pull/1#discussion_r29724692|#10>] ▁♕₅ baxterthehacker: +1\n>>>+1 this is a great idea.")
    end

    it 'sends a message when comment body includes "++"' do
      handler = CommentAddedEventHandler.new(generate_comment_payload('++ hero!'))
      expect(handler.execute!(redis)).to eq("[<http://github.com/baxterthehacker/public-repo|review:public-repo> <https://github.com/baxterthehacker/public-repo/pull/1#discussion_r29724692|#10>] ▁♕₅ baxterthehacker: ++\n>>>++ hero!")
    end

  end
end
