# frozen_string_literal: true

text_scores = ARGV[0].split(',')
scores = text_scores.flat_map { |text_score| text_score == 'X' ? [10, 0] : text_score.to_i }
frames = scores.each_slice(2).to_a
total_score =
  frames.each_with_index.sum do |frame, index|
    strike = (frame[0] == 10)
    spare = (!strike && frame.sum == 10)
    last_frame = (index + 1 >= 10)
    next_frame = (frames[index + 1])
    after_next_frame = (frames[index + 2])
    if last_frame
      frame.sum
    elsif strike
      double = (next_frame[0] == 10)
      if double
        after_next_frame[0] + 20
      else
        next_frame.sum + 10
      end
    elsif spare
      next_frame[0] + 10
    else
      frame.sum
    end
  end
puts total_score
