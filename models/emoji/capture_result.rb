module Emoji
  class CaptureResult
    attr_reader :emoji

    def initialize(emoji, captured)
      @emoji = emoji
      @captured = captured
    end

    def captured?
      @captured
    end

    def format(user)
      if captured?
        "A wild #{emoji} appears.\n#{user} captured #{emoji}"
      else
        "A wild #{emoji} appears, but #{user} couldn't capture it."
      end
    end
  end
end
