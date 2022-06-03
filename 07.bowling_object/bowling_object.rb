# frozen_string_literal: true

require_relative 'game'

def main
  game1 = Game.new(ARGV[0])
  game1.total_score
  puts game1.game_score
end

main
