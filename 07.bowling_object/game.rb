# frozen_string_literal: true

require_relative 'frame'

class Game
  attr_reader :game_score

  def initialize(scores)
    @scores = scores.split(',')
    @frame_scores = []
  end

  def total_score
    number_scores = convert_number_scores
    frame_scores = convert_frames_shot(number_scores)
    @game_score = game_scores(frame_scores)
  end

  def convert_number_scores
    @scores.flat_map { |score| score == 'X' ? [10, 0] : score.to_i }
           .each_slice(2).collect { |number_score| number_score }
  end

  def convert_frames_shot(number_scores)
    # 10投になるようにダミー追加
    number_scores.fill([0, 0], number_scores.size, 12 - number_scores.size)
    number_scores.each_cons(3).with_index do |number_score, index|
      @frame_scores << number_score if index < 10
    end
    @frame_scores
  end

  def game_scores(frame_scores)
    frame_scores.map.with_index do |frame_score, index|
      frame = Frame.new(frame_score[0], frame_score[1], frame_score[2])
      frame.score(index)
    end.sum
  end
end
