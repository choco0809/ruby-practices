# frozen_string_literal: true

require 'optparse'

SPACE_STRING = '0x0c|0x0a|0x0d|0x09|0x0b|0xa0|0x85'

def main
  # オプションの初期化
  options = { l: false }
  opt = OptionParser.new
  opt.on('-l', '入力ファイルの行数を標準出力に出力します。改行コードの数を行数とします。') { options[:l] = true }
  if (arguments = opt.parse(ARGV)) && arguments.size.positive?
    process_not_stdin(arguments, **options)
  else
    process_stdin($stdin.read, **options)
  end
end

def process_not_stdin(file_paths, options)
  total_summary = []
  file_paths.each do |input_content|
    if FileTest.directory? input_content
      puts "wc: #{input_content}: read: Is a directory"
      files_list = { name: nil, size: 0, word_count: 0, line_count: 0 }
      total_summary.push(files_list)
    elsif FileTest.file? input_content
      full_path = File.expand_path(input_content)
      read_contents = File.read(full_path)
      files_list = create_files_list(input_content, read_contents)
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

def process_stdin(stdin_strings, options)
  stdin_list = create_files_list(nil, stdin_strings)
  puts_wc(stdin_list, **options)
end

# files_listを作成する
def create_files_list(name, contents)
  {
    name: name,
    size: contents.bytesize,
    word_count: word_count(contents),
    line_count: line_count(contents)
  }
end

# 単語の数取を得
def word_count(string)
  hex_number = convert_hex_number(string)
  # タブ等を0x20に統一
  hex_number.gsub!(/#{SPACE_STRING}/, '0x20')
  hex_number = delete_consecutive_0x20(hex_number)
  hex_number.split('0x20').count.to_i
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
def line_count(string)
  string.scan("\n").count.to_i
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
