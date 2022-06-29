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
end
