# frozen_string_literal: true

# lsコマンドを実行した時に、横に表示させる最大数
COLUMNS = 3

# マルチバイトに対応したljust
class String
  def multi_byte_ljust(width, padding = ' ')
    strings_bytesize = each_char.map { |string| string.bytesize == 1 ? 1 : 2 }.sum
    padding_count = [0, width - strings_bytesize].max
    ljust(size + padding_count, padding)
  end
end

# カラム数から行数を求める
def cal_row_count(columns, files)
  (files.count.to_f / columns).ceil
end

# 対象ディレクトリに存在するファイル一覧を取得する
def create_files_text(directory)
  Dir.glob('*', base: directory, sort: true)
end

# ファイル一覧を行数で分割する
def convert_files_text(row_count, files, max_length)
  files.each_slice(row_count).map do |file|
    # ファイル名の長さを統一する
    unify_lengths_file = file.map { |f| f.multi_byte_ljust(max_length) }
    # 配列内の要素がカラムに足りていない場合ダミーを追加
    row_count <= unify_lengths_file.count ? unify_lengths_file : add_dummy(unify_lengths_file, row_count)
  end.transpose
end

# ファイル名が一番大きいサイズを取得する
def max_file_length(files)
  files.map(&:length).max
end

# ダミー行を追加する
def add_dummy(array, row_count)
  if array.size < row_count
    array.fill(nil, array.size, row_count - array.size)
  else
    array
  end
end

# ファイルを出力する
def print_files(files)
  files.map do |file|
    file.join('   ')
  end.join("\n")
end

def main(target_directory)
  # 作業ディレクトリの指定
  files_text = create_files_text(target_directory)
  max_file_name_length = max_file_length(files_text)
  row_count = cal_row_count(COLUMNS, files_text)
  files = convert_files_text(row_count, files_text, max_file_name_length)
  print_files(files)
end

if __FILE__ == $PROGRAM_NAME # rubocop:disable Style/IfUnlessModifier
  target_directory = ARGV.first || '.'
  puts main(target_directory)
end
