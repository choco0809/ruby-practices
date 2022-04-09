# frozen_string_literal: true

require 'optparse'

SPACE_STRING = '0x0c|0x0a|0x0d|0x09|0x0b|0xa0|0x85'

def main
  # オプションの初期化
  options = { l: false }
  opt = OptionParser.new
  opt.on('-l', '入力ファイルの行数を標準出力に出力します。改行コードの数を行数とします。') { options[:l] = true }
  argument_flg = opt.parse(ARGV).first.nil? ? false : true
  input_contents = argument_flg ? opt.parse(ARGV) : $stdin.read
  # total_summary = []
  if argument_flg
    process_has_argument_flg(input_contents, **options)
  else
    # 標準入力の場合
    process_without_argument_flg(input_contents, **options)
  end
end

# 引数ありの処理
def process_has_argument_flg(input_contents, options)
  total_summary = []
  input_contents.each do |input_content|
    if FileTest.directory? input_content
      puts "wc: #{input_content}: read: Is a directory"
      files_list = { name: nil, size: 0, word_count: 0, line_count: 0 }
      total_summary.push(files_list)
    elsif FileTest.file? input_content
      full_path = File.expand_path(input_content)
      stat_file = File::Stat.new(full_path)
      read_contents = IO.readlines(full_path).join
      files_list = create_files_list(input_content, stat_file, read_contents, read_contents)
      total_summary.push(files_list)
      puts_wc(files_list, **options)
    else
      puts "wc: #{input_content}: open: No such file or directory"
      files_list = { name: nil, size: 0, word_count: 0, line_count: 0 }
      total_summary.push(files_list)
    end
  end
  total_summary.count > 1 ? puts_total_summary(total_summary, **options) : nil
end

# 引数なしの処理
def process_without_argument_flg(input_contents, options)
  files_list = create_files_list(nil, input_contents, input_contents, input_contents)
  puts_wc(files_list, **options)
end

# files_listを作成する
def create_files_list(name, size, word_count, line_count)
  {
    name: name,
    size: get_size(size),
    word_count: get_word_count(word_count),
    line_count: get_line_count(line_count)
  }
end

# 容量（バイト）取得
def get_size(string)
  string.is_a?(String) ? string.bytesize : string.size
end

# 単語の数取を得
def get_word_count(string)
  hex_number_string = convert_hex_number(string)
  # タブ等を0x20に統一
  hex_number_string.gsub!(/#{SPACE_STRING}/, '0x20')
  hex_number_string = delete_consecutive_0x20(hex_number_string)
  hex_number_string.split('0x20').count
end

# 16進数に変換する
def convert_hex_number(convert_strings)
  # 16進数に整形（0x~）
  convert_strings.unpack('H*').join.scan(/.{1,2}/).map { |convert_string| "0x#{convert_string}" }.join
end

# 連続した0x20を削除
def delete_consecutive_0x20(string)
  if string.scan('0x200x20').count.positive?
    string.gsub!('0x200x20', '0x20')
    delete_consecutive_0x20(string)
  else
    string
  end
end

# 改行コードの数を取得
def get_line_count(string)
  string.scan("\n").count
end

# wcコマンドの出力を整形
def puts_wc(files_list, options)
  puts_wc_string =
    if options[:l]
      "#{files_list[:line_count].to_s.rjust(8)} "\
      "#{files_list[:name]}"
    else
      "#{files_list[:line_count].to_s.rjust(8)}"\
      "#{files_list[:word_count].to_s.rjust(8)}"\
      "#{files_list[:size].to_s.rjust(8)} "\
      "#{files_list[:name]}"
    end
  puts puts_wc_string
end

# 引数が複数の場合、total_summaryを出力する
def puts_total_summary(total_summary, options)
  sum_line_count = total_summary.map { |summary| summary[:line_count] }.sum.to_s.rjust(8)
  sum_word_count = total_summary.map { |summary| summary[:word_count] }.sum.to_s.rjust(8)
  sum_size = total_summary.map { |summary| summary[:size] }.sum.to_s.rjust(8)
  puts_wc_string =
    if options[:l]
      "#{sum_line_count} total"
    else
      "#{sum_line_count}" \
      "#{sum_word_count}" \
      "#{sum_size} total"
    end
  puts puts_wc_string
end

main
