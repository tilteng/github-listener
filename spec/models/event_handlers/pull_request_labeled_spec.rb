require_relative "../../../models/event_handlers/pull_request_labeled_event_handler"

describe PullRequestLabeledEventHandler do
  describe '#execute' do
    it 'does nothing for an arbitary label' do
      redis = double(:redis)

      channel = 'cool channel'
      handler = PullRequestLabeledEventHandler.new({
        'label' => {
            'name' => 'Not a label'
        }
      })
      expect(handler.execute!(redis)).to eq(nil)
    end

    it 'sends a message when the label is "Needs review"' do
      redis = double(:redis)
      allow(redis).to receive(:get).with('baxterthehacker') { 500 }
      allow(redis).to receive(:set).with('baxterthehacker', 501)

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
      expect(handler.execute!(redis)).to eq("[<http://github.com/baxterthehacker/public-repo|review:public-repo> <https://github.com/baxterthehacker/public-repo/pull/1|#10>] ▁♕₅ baxterthehacker: Needs review\n>>>An important pull request")
    end
  end
end
