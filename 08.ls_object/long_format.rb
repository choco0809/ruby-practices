# frozen_string_literal: true

require 'etc'
require_relative 'manipulate_list_segment'

class LongFormat

  def initialize(target_directory, options)
    @target_directory = target_directory
    @options = options
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

  def fetch_files_mode(files_mode)
    # パーミッション種類を取得
    permission_strings =
      files_mode[-3, 3].each_char.each_with_object([]) do |file_mode, permission_strings|
        permission_strings << permission_type_list(file_mode.to_i)
      end
    # ファイル種類を取得
    file_type =
      if files_mode.length > 5
        file_type_list(files_mode[0, 2].to_i)
      else
        file_type_list(files_mode[0, 1].to_i)
      end
    file_type + permission_strings.join
  end

  def fetch_files_info(files)
    files.map do |file|
      stat_file = File::Stat.new(File.expand_path(file, @target_directory))
      file_mode_string = fetch_files_mode(stat_file.mode.to_s(8))
      {
        file_name: file,
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

  def show_list_segments
    manipulate_list_segment = ManipulateListSegment.new(@target_directory, **@options)
    list_segments = manipulate_list_segment.create_list_segments
    files_info = fetch_files_info(list_segments)
    block_size_total = files_info.sum { |hash| hash[:block_size] }
    hard_link_max = files_info.map { |v| v[:hard_link].length }.max
    file_size_max = files_info.map { |v| v[:file_size].length }.max
    "total #{block_size_total}\n" + files_info.map do |file_info|
        "#{file_info[:permission]}  "\
        "#{file_info[:hard_link].rjust(hard_link_max)} "\
        "#{file_info[:owner_name]}  "\
        "#{file_info[:group_name]}  "\
        "#{file_info[:file_size].rjust(file_size_max)} "\
        "#{file_info[:time_stamp]} "\
        "#{file_info[:file_name]}"
      end.join("\n")
  end

end
