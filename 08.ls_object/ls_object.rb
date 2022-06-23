# frozen_string_literal: true

require 'optparse'
require_relative 'short_format'
require_relative 'long_format'

COLUMNS = 3

def main(target_directory, options)
  if options[:l]
    long_format = LongFormat.new(target_directory, **options)
    long_format.show_list_segments
  else
    short_format = ShortFormat.new(target_directory, COLUMNS, **options)
    short_format.show_list_segments
  end
end

if __FILE__ == $PROGRAM_NAME
  options = { a: false, r: false, l: false }
  opt = OptionParser.new
  opt.on('-a', '--all', 'do not ignore entries starting with') { options[:a] = true }
  opt.on('-r', '--reverse', 'reverse order while sorting') { options[:r] = true }
  opt.on('-l', '詳細リスト形式を表示する') { options[:l] = true }
  target_directory = opt.parse(ARGV).first || '.'
  puts main(target_directory, **options)
end
