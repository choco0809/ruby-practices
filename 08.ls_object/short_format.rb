# frozen_string_literal: true

class ShortFormat
  def initialize(target_directory, columns, options)
    @target_directory = target_directory
    @options = options
    @columns = columns
  end

  def list_segments
    # manipulate_list_segment = ManipulateListSegment.new(@target_directory, **@options)
    list_segments = create_list_segments(@target_directory, **@options)
    max_length = list_segments.map(&:length).max
    row_count = (list_segments.count.to_f / @columns).ceil
    list_segments_text = convert_list_segments(row_count, list_segments, max_length)
    list_segments_text.map { |f| f.join("\t").rstrip }.join("\n")
  end

  private

  def create_list_segments(target_directory, options)
    ls_text =
      if options[:a]
        Dir.glob('*', File::FNM_DOTMATCH, base: target_directory)
      else
        Dir.glob('*', base: target_directory)
      end
    options[:r] ? ls_text.reverse : ls_text
  end

  def convert_list_segments(row_count, files, max_length)
    files.each_slice(row_count).map do |file|
      unify_lengths_file = file.map { |f| f.ljust(max_length) }
      row_count <= unify_lengths_file.count ? unify_lengths_file : add_dummy(unify_lengths_file, row_count)
    end.transpose
  end

  def add_dummy(array, row_count)
    array.size < row_count ? array.fill(nil, array.size, row_count - array.size) : array
  end

end
