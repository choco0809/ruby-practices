# 今月のカレンダーを表示するプログラムを書いてみよう。（コマンドラインのプログラムとして作ろう）
require 'optparse'
require 'date'

class Calendar
    attr_reader :year
    attr_reader :month
    def set_year(value)
        @year = is_number(value) && value.to_s.size == 4 ? value.to_i : Date.today.year
    end
    def set_month(value)
        @month = is_number(value) && value.to_s.size < 3 && value.to_i < 13 ? value.to_i : Date.today.month
    end
    def reverse_color(mday,space)
        if @year == Date.today.year && @month == Date.today.month && mday == Date.today.mday
            "\e[47m\e[30m#{mday}\e[0m".rjust(space + 14)
        else 
            mday.to_s.rjust(space)
        end
    end
end

# 数値に変換できか判断
def is_number(value)
    value.to_s.match?(/^[0-9]+$/)
end

# -y -m オプション指定
params = {}
opt = OptionParser.new
opt.on('-y [val]','--year','年（yyyy）を指定'){ |v| params[:year] = v}
opt.on('-m [val]','--month','月（mm/m）を指定'){ |v| params[:month] = v}
opt.parse!(ARGV)

# -y -m オプションが正しく指定されなかった時は現在の年、月を指定
calendar = Calendar.new
calendar.set_year(params[:year])
calendar.set_month(params[:month])

# カレンダー表示
first_day = Date.new(calendar.year,calendar.month)
last_day = first_day.next_month(1).prev_day(1)

puts "      #{first_day.month}月 #{first_day.year}      "
puts "日 月 火 水 木 金 土"
(1..last_day.mday).each_with_index do |date,index|
    if index == 0
        print calendar.reverse_color(date,3*first_day.next_day(index).wday+2)
    elsif first_day.next_day(index).sunday?
        print calendar.reverse_color(date,2)
    elsif first_day.next_day(index).saturday?
        puts calendar.reverse_color(date,3)
    else
        print calendar.reverse_color(date,3)
    end
end
puts
