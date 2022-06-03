# frozen_string_literal: true

class Frame
  def initialize(frame, next_frame, after_next_frame)
    @frame = frame
    @next_frame = next_frame
    @after_next_frame = after_next_frame
  end

  def score(index)
    strike = (@frame[0] == 10)
    spare = (!strike && @frame.sum == 10)
    last_frame = (@frame if index > 8)
    if last_frame
      @frame.sum + @next_frame.sum + @after_next_frame.sum
    elsif strike
      double = (@next_frame[0] == 10)
      double ? @after_next_frame[0] + 20 : @next_frame.sum + 10
    elsif spare
      @next_frame[0] + 10
    else
      @frame.sum
    end
  end
end
