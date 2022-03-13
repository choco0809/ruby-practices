# frozen_string_literal: true

# 配列内の要素数をslice_countの個数に統一する
def align_slice_count(array, slice_count)
  if array.size < slice_count
    array.push(nil)
    align_slice_count(array, slice_count)
  else
    array
  end
end

# マルチバイトに対応したljust
class String
  def multi_byte_ljust(width, padding = ' ')
    strings_bytesize = each_char.map { |string| string.bytesize == 1 ? 1 : 2 }.sum
    padding_count = [0, width - strings_bytesize].max
    self + padding * padding_count
  end
end

width = 3
directory = ARGV[0].nil? == true ? '.' : ARGV[0]
files_text = Dir.glob('*', base: directory).sort
max_string_length = files_text.map(&:length).max
files_text.map! { |file_text| file_text.multi_byte_ljust(max_string_length) }
files_text = align_slice_count(files_text, width)
remainder_of_zero = (files_text.size % width).zero?
width =
  if remainder_of_zero
    files_text.size / width
  else
    files_text.size / width + 1
  end
files =
  files_text.each_slice(width).map do |file_text|
    align_slice_count(file_text, width)
  end
if files_text.size <= width
  puts files_text.join("\t")
else
  files.transpose.each { |file| puts file.join("\t") }
end
