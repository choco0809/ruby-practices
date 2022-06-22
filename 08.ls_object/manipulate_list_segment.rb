# frozen_string_literal: true

class ManipulateListSegment

  def initialize(target_directory, options)
    @target_directory = target_directory
    @options = options
  end

  def create_list_segments
    ls_text =
      if @options[:a]
        Dir.glob('*', File::FNM_DOTMATCH, base: @target_directory)
      else
        Dir.glob('*', base: @target_directory)
      end
    @options[:r] ? ls_text.reverse : ls_text
  end

  def convert_list_segments(row_count, files, max_length)
    files.each_slice(row_count).map do |file|
      unify_lengths_file = file.map { |f| f.ljust(max_length) }
      row_count <= unify_lengths_file.count ? unify_lengths_file : add_dummy(unify_lengths_file, row_count)
    end.transpose
  end

  def add_dummy(array, row_count)
    if array.size < row_count
      array.fill(nil, array.size, row_count - array.size)
    else
      array
    end
  end

end
