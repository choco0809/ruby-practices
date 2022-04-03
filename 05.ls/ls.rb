# frozen_string_literal: true

require 'optparse'
require 'etc'
WIDTH = 3

# オプション情報からファイルの一覧を作成
def create_files_text(directory, ls_options)
  ls_texts =
    if ls_options[:a]
      Dir.glob('*', File::FNM_DOTMATCH, base: directory)
    else
      Dir.glob('*', base: directory)
    end
  ls_options[:r] ? ls_texts.reverse : ls_texts
end

# マルチバイトに対応したljust
class String
  def multi_byte_ljust(width, padding = ' ')
    strings_bytesize = each_char.map { |string| string.bytesize == 1 ? 1 : 2 }.sum
    padding_count = [0, width - strings_bytesize].max
    ljust(size + padding_count, padding)
  end
end

# 表示するファイル数（横幅）を取得
def get_slice_element_count(files_text)
  max_string_length = files_text.map(&:length).max
  files_text.map! { |file_text| file_text.multi_byte_ljust(max_string_length) }
  files_text = align_slice_count(files_text, WIDTH)
  remainder_of_zero = (files_text.size % WIDTH).zero?
  remainder_of_zero ? 1 : files_text.size / WIDTH + 1
end

# 配列内の要素数をslice_countの値に統一する
def align_slice_count(array, slice_count)
  if array.size < slice_count
    array.fill(nil, array.size, slice_count - array.size)
  else
    array
  end
end

# ファイルの情報を取得
def get_files_info(files_text, directory)
  files_text.map do |file_text|
    stat_file = File::Stat.new(File.expand_path(file_text, directory))
    file_mode_string = get_file_mode(stat_file.mode.to_s(8))
    {
      file_name: file_text,
      block_size: stat_file.blocks,
      permission: file_mode_string,
      hard_link: stat_file.nlink.to_s,
      owner_name: Etc.getpwuid(stat_file.uid).name,
      group_name: Etc.getgrgid(stat_file.gid).name,
      file_size: stat_file.size.to_s,
      time_stamp: stat_file.mtime.strftime('%_m %_d %H:%M')
    }
  end
end

# パーミッション種類
def permission_type_list(permission_number)
  permission_type = {
    0 => '---', 1 => '--x', 2 => '-w-', 3 => '-wx',
    4 => 'r--', 5 => 'r-x', 6 => 'rw-', 7 => 'rwx'
  }
  permission_type[permission_number]
end

# ファイル種類
def file_type_list(file_number)
  files_type = {
    1 => 'p', 2 => 'c', 4 => 'd', 6 => 'b',
    10 => '-', 12 => 'l', 14 => 's'
  }
  files_type[file_number]
end

# ファイルモード取得
def get_file_mode(files_mode)
  # パーミッションの種類を取得
  permission_strings = []
  files_mode[-3, 3].each_char do |file_mode|
    permission_strings.push(permission_type_list(file_mode.to_i))
  end
  # ファイルの種類を判断
  file_type = files_mode.length > 5 ? file_type_list(files_mode[0, 2].to_i) : file_type_list(files_mode[0, 1].to_i)
  file_type + permission_strings.join
end

# lオプション指定なしの場合の出力
def print_ls(files_text)
  slice_element_count = get_slice_element_count(files_text)
  files =
    files_text.each_slice(slice_element_count).map do |slice_files|
      align_slice_count(slice_files, slice_element_count)
    end
  if slice_element_count == 1
    puts files.join("\t")
  else
    files.transpose.each { |file| puts file.join("\t") }
  end
end

# lオプション指定ありの場合の出力
def print_ls_l_option(files_text, directory)
  files_info = get_files_info(files_text, directory)
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

# オプションの初期化
options = { a: false, r: false, l: false }
opt = OptionParser.new
opt.on('-a', '--all', 'do not ignore entries starting with') { options[:a] = true }
opt.on('-r', '--reverse', 'reverse order while sorting') { options[:r] = true }
opt.on('-l', '詳細リスト形式を表示する') { options[:l] = true }
# 作業ディレクトリの設定
directory = opt.parse(ARGV).first || '.'
files_text = create_files_text(directory, **options)
if options[:l]
  print_ls_l_option(files_text, directory)
else
  print_ls(files_text)
end
