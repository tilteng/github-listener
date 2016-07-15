module UserExperience
  class User
    TITLES   = [ '☹₀', '♙₁', '♘₂', '♗₃', '♖₄', '♕₅', '♔₆', '☃₇', '☼₈', '⚛₉', '☯₁₀', '⌘₁₁', '⍟₁₂', '⌹₁₃', '⍰₁₄', '⏏₁₅', '▜₁₆', '☆₁₇', '☕₁₈', '☢₁₉', '☘₂₀', ':cuteghost:₂₁', ':tiltlogo:₂₂', ':ship3:₂₃', ':ocean:₂₄', ':zap:₂₅', ':cherries:₂₆', ':heart_decoration:₂₇', ':game_die:₂₈', ':helicopter:₂₉', ':science:₃₀' ]
    EXPBAR   = [ '▁', '▂', '▃', '▅', '▆', '▇', '█' ]
    FACTOR   = 100
    INTERVAL = FACTOR.to_f / EXPBAR.size.to_f

    def initialize(redis, login)
      @redis = redis
      @login = login
    end

    def increment
      @redis.set @login, redis_experience + 1
    end

    def display
      "#{score_icon} #{@login}"
    end

  private

    def icon
      score = redis_experience
      return '' if score <= 0
      return EXPBAR[ ((score % FACTOR) / INTERVAL).to_i ]
    end

    def redis_experience
      @redis.get(@login).to_i
    end

    def score_icon
      score = redis_experience
      return '☃'                 if @login == 'tildedave'
      return "#{icon}:bestgoat:" if @login == 'liuhenry'
      return '☠'                 if score <= 0
      return ':godmode:₉₉'       if score >= (TITLES.size * FACTOR)
      return "#{icon}#{TITLES[ score / FACTOR ]}"
    end
  end
end
