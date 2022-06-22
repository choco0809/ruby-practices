# frozen_string_literal: true

require_relative 'manipulate_list_segment'

class ShortFormat
  def initialize(target_directory, columns, options)
    @target_directory = target_directory
    @options = options
    @columns = columns
  end

  def show_list_segments
    manipulate_list_segment = ManipulateListSegment.new(@target_directory, **@options)
    list_segments = manipulate_list_segment.create_list_segments
    max_length = list_segments.map(&:length).max
    row_count = (list_segments.count.to_f / @columns).ceil
    list_segments_text = manipulate_list_segment.convert_list_segments(row_count, list_segments, max_length)
    list_segments_text.map { |f| f.join("\t") }.join("\n")
  end
end
