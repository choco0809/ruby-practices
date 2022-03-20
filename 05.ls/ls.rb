# frozen_string_literal: true

require 'optparse'
WIDTH = 3

# 配列内の要素数をslice_countの個数に統一する
def align_slice_count(array, slice_count)
  if array.size < slice_count
    array.fill(nil, array.size, slice_count - array.size)
  else
    array
  end
end

# マルチバイトに対応したljust
class String
  def multi_byte_ljust(width, padding = ' ')
    strings_bytesize = each_char.map { |string| string.bytesize == 1 ? 1 : 2 }.sum
    padding_count = [0, width - strings_bytesize].max
    ljust(size + padding_count, padding)
  end
end

options = {}
options = { a: false }
opt = OptionParser.new
opt.on('-a', '--all', 'do not ignore entries starting with') { options[:a] = true }
directory = opt.parse(ARGV).first || '.'
files_text =
  if options[:a] == true
    Dir.glob('*', File::FNM_DOTMATCH, base: directory)
  else
    Dir.glob('*', base: directory).sort
  end
max_string_length = files_text.map(&:length).max
files_text.map! { |file_text| file_text.multi_byte_ljust(max_string_length) }
files_text = align_slice_count(files_text, WIDTH)
remainder_of_zero = (files_text.size % WIDTH).zero?
slice_element_count =
  if remainder_of_zero
    files_text.size / WIDTH
  else
    files_text.size / WIDTH + 1
  end
files =
  files_text.each_slice(slice_element_count).map do |slice_files|
    align_slice_count(slice_files, slice_element_count)
  end
if files_text.size <= slice_element_count
  puts files_text.join("\t")
else
  files.transpose.each { |file| puts file.join("\t") }
end
