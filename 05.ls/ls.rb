# frozen_string_literal: true

require 'optparse'
require 'etc'
WIDTH = 3

# パーミッション種類
def permission_type_list(permission_number)
  permission_type = {
    0 => '---', 1 => '--x', 2 => '-w-', 3 => '-wx',
    4 => 'r--', 5 => 'r-x', 6 => 'rw-', 7 => 'rwx'
  }
  permission_type[permission_number]
end

def file_type_list(file_number)
  files_type = {
    1 => 'p', 2 => 'c', 4 => 'd', 6 => 'b',
    10 => '-', 12 => 'l', 14 => 's'
  }
  files_type[file_number]
end

def get_permission_type(permission_numbers)
  # パーミッションの種類を取得
  permission_strings = []
  permission_numbers[-3, 3].each_char do |permission_number|
    permission_strings.push(permission_type_list(permission_number.to_i))
  end
  # ファイルの種類を判断
  permission_strings.join +
    if permission_numbers.length > 5
      file_type_list(permission_numbers[0, 2].to_i)
    else
      file_type_list(permission_numbers[0, 1].to_i)
    end
end

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

# lsオプションによってfiles_textを生成
def create_files_text(directory, ls_options)
  ls_texts =
    if ls_options[:a]
      Dir.glob('*', File::FNM_DOTMATCH, base: directory)
    else
      Dir.glob('*', base: directory)
    end
  ls_options[:r] == true ? ls_texts.reverse : ls_texts
end

def get_files_info_l_option(files_text, directory)
  files_text.map do |file_text|
    stat_file = File::Stat.new(File.expand_path(file_text, directory))
    permission_string = get_permission_type(stat_file.mode.to_s(8))
    {
      file_name: file_text,
      block_size: stat_file.blocks,
      permission: permission_string,
      hard_link: stat_file.nlink.to_s,
      owner_name: Etc.getpwuid(stat_file.uid).name,
      group_name: Etc.getgrgid(stat_file.gid).name,
      file_size: stat_file.size.to_s,
      time_stamp: stat_file.mtime.strftime('%_m %_d %H:%M')
    }
  end
end

def print_ls_l_option(files_info)
  block_size_total = files_info.sum { |hash| hash[:block_size] }
  # 各種値の最大値を取得
  hard_link_max = files_info.map { |v| v[:hard_link].length }.max
  file_size_max = files_info.map { |v| v[:file_size].length }.max
  puts "total #{block_size_total}"
  files_info.each do |file_info|
    puts "#{file_info[:permission]}  "\
          "#{file_info[:hard_link].rjust(hard_link_max)} "\
          "#{file_info[:owner_name]}  "\
          "#{file_info[:group_name]}  "\
          "#{file_info[:file_size].rjust(file_size_max)} "\
          "#{file_info[:time_stamp]} "\
          "#{file_info[:file_name]}"
  end
end

def print_ls(files_text, slice_element_count)
  files =
    files_text.each_slice(slice_element_count).map do |slice_files|
      align_slice_count(slice_files, slice_element_count)
    end
  if files_text.size <= slice_element_count
    puts files.join("\t")
  else
    files.transpose.each { |file| puts file.join("\t") }
  end
end

def get_slice_element_count(files_text)
  max_string_length = files_text.map(&:length).max
  files_text.map! { |file_text| file_text.multi_byte_ljust(max_string_length) }
  files_text = align_slice_count(files_text, WIDTH)
  remainder_of_zero = (files_text.size % WIDTH).zero?
  remainder_of_zero ? files_text.size / WIDTH : files_text.size / WIDTH + 1
end

options = { a: false, r: false, l: false }
opt = OptionParser.new
opt.on('-a', '--all', 'do not ignore entries starting with') { options[:a] = true }
opt.on('-r', '--reverse', 'reverse order while sorting') { options[:r] = true }
opt.on('-l', '詳細リスト形式を表示する') { options[:l] = true }
directory = opt.parse(ARGV).first || '.'
files_text = create_files_text(directory, **options)
if options[:l]
  files_info = get_files_info_l_option(files_text, directory)
  print_ls_l_option(files_info)
else
  slice_element_count = get_slice_element_count(files_text)
  print_ls(files_text, slice_element_count)
end
