# frozen_string_literal: true

class Frame
  def initialize(frame, next_frame, after_next_frame)
    @frame = frame
    @next_frame = next_frame
    @after_next_frame = after_next_frame
  end

  def score(index)
    if index > 8
      last_frame
    elsif @frame.sum == 10
      spare + strike
    else
      @frame.sum
    end
  end

  def last_frame
    [@frame, @next_frame, @after_next_frame].flatten.sum
  end

  def spare
    @frame[0] != 10 ? @next_frame[0] + 10 : 0
  end

  def strike
    if @frame[0] == 10
      @next_frame[0] == 10 ? @after_next_frame[0] + 20 : @next_frame.sum + 10
    else
      0
    end
  end
end
