module Emoji
  class Server
    def initialize(redis)
      @redis = redis
    end

    def push(user_id, emoji)
      @redis.lpush("#{user_id}_pets", emoji)
    end

    def list(user_id, start_index, end_index)
      @redis.lrange("#{user_id}_pets", start_index, end_index)
    end
  end
end
