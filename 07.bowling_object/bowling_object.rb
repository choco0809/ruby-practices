# frozen_string_literal: true

require_relative 'game'

def main(scores)
  game1 = Game.new(scores)
  game1.total_score
end

if __FILE__ == $PROGRAM_NAME # rubocop:disable Style/IfUnlessModifier
  puts main(ARGV[0])
end
