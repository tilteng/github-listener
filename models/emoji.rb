require_relative './emoji/capture_result'
require_relative './emoji/server'

module Emoji
  class Manager
    attr_reader :server
    def initialize(redis)
      @server = Server.new(redis)
    end

    def list
      %w[
        :parrot: :pacman: :pig: :octopus: :chicken: :crickets: :bee: :bird:
        :crocodile: :ghost2: :rooster: :best: :turkey: :corgi: :doge:
      ]
    end

    def battle(user)
      emoji_list = self.list
      emoji = emoji_list[rand(emoji_list.count)]
      result = CaptureResult.new(emoji, rand(2) == 0)
      if result.captured?
        self.server.push(user, result.emoji)
      end
      return result
    end

    def random_encounter(user)
      emoji_list = self.list
      emoji = emoji_list[rand(emoji_list.count)]

      if rand(5) == 0
        return battle(user)
      end
      return nil
    end
  end
end
