require_relative "../../../models/event_handlers/pull_request_labeled_event_handler"

describe PullRequestLabeledEventHandler do
  describe '#execute' do
    it 'does nothing for an arbitary label' do
      slack = double(:slack)
      channel = 'cool channel'
      handler = PullRequestLabeledEventHandler.new({})
      expect(handler.execute!(slack, channel)).to eq(nil)
    end

    it 'sends a message when the label is "Needs review"' do
      slack = double(:slack)
      allow(slack).to receive(:post_message!) { |channel_id, message| message }
      expect(slack).to receive(:post_message).with('#cool-channel', '[<http://github.com/baxterthehacker/public-repo|review:public-repo> <https://github.com/baxterthehacker/public-repo/pull/1|#10>] baxterthehacker: Needs review :git:>>>An important pull request')

      handler = PullRequestLabeledEventHandler.new({
        'repository' => {
          'name' => 'public-repo',
          'full_name' =>  'baxterthehacker/public-repo',
        },
        "comment": {
          "html_url": "https://github.com/baxterthehacker/public-repo/pull/1#discussion_r29724692",
        },
        'pull_request' => {
          'html_url' => 'https://github.com/baxterthehacker/public-repo/pull/1',
          'number' => 10,
          'title' => 'An important pull request',
          'user' => {
            'login' => 'baxterthehacker'
          }
        },
        'label' => {
          'name' => 'Needs review'
        }
      })
      handler.execute!(slack, '#cool-channel')
    end
  end
end
