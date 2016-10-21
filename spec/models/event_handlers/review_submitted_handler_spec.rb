require_relative "../../../models/event_handlers/review_submitted_handler"

# approved / changes_requested

def generate_review_submitted_payload(state, body)
  {
  	"action" => "submitted",
    "review" => {
      "user" => {
        "login" => "baxterthehacker",
        "html_url" => "https://github.com/baxterthehacker",
      },
      "body" => body,
      "state" => state,
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

describe ReviewSubmittedHandler do
  describe '#execute' do
    it 'does nothing for a "changes_requested" review' do
      redis = double(:redis)
      allow(redis).to receive(:get).with('baxterthehacker') { 5 }
      allow(redis).to receive(:set).with('baxterthehacker', 6)

      payload = generate_review_submitted_payload("changes_requested", 'this pr does not lgtm')
      handler = ReviewSubmittedHandler.new(payload)
      expect(handler.execute!(redis)).to eq(nil)
    end

    it 'sends a message when "approved" review' do
      redis = double(:redis)
      allow(redis).to receive(:get).with('baxterthehacker') { 500 }
      allow(redis).to receive(:set).with('baxterthehacker', 501)

      payload = generate_review_submitted_payload('approved', 'this pr lgtm.')
      handler = ReviewSubmittedHandler.new(payload)
      expect(handler.execute!(redis)).to eq("[<http://github.com/baxterthehacker/public-repo|review:public-repo> https://github.com/baxterthehacker/public-repo/pull/1#discussion_r29724692] ▁♕₅ baxterthehacker: looks good\n>>>this pr lgtm.")
    end
  end
end
