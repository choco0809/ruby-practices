#今月のカレンダーを表示するプログラムを書いてみよう。（コマンドラインのプログラムとして作ろう）
require 'optparse'
require 'date'

class Calendar
    def set_year(value)
        @year = IsNumber(value) == true && value.to_s.size == 4 ? value.to_i : Date.today.year
    end
    def set_month(value)
        @month = IsNumber(value) == true && value.to_s.size < 3 && value.to_i < 13 ? value.to_i : Date.today.month
    end
    def year
        @year
    end
    def month
        @month
    end
    # 現在の日付の場合、色を反転させる
    def ReverseColor(value)
        @year == Date.today.year && @month == Date.today.month && value == Date.today.mday ? "\e[47m\e[30m#{value}\e[0m" : value
    end
end

#1週目の位置調整のためスペースを出力する
def AddSpaceWday(today)
    today.wday.times{print "   "}
end

# 数値に変換できか判断
def IsNumber(value)
    !(value.to_s =~ /^[0-9]+$/) == false
end

#-y -m オプション指定
params = {}
opt = OptionParser.new
opt.on('-y [val]','--year','年（yyyy）を指定'){ |v| params[:year] = v}
opt.on('-m [val]','--month','月（mm/m）を指定'){ |v| params[:month] = v}
opt.parse!(ARGV)

#-y -m オプションが正しく指定されなかった時は現在の年、月を指定
calendar = Calendar.new
calendar.set_year(params[:year])
calendar.set_month(params[:month])

#カレンダー表示
first_day = Date.new(calendar.year,calendar.month)
last_day = first_day.next_month(1).prev_day(1)
calendar_arry = [*1..last_day.mday]
puts "      #{first_day.month}月 #{first_day.year}      "
puts "日 月 火 水 木 金 土"
calendar_arry.each do |date|
    AddSpaceWday(first_day) if date == 1
    if first_day.next_day(date-1).saturday? == true or last_day.mday == date
        puts date < 10 ? " #{calendar.ReverseColor(date)}" : calendar.ReverseColor(date)
    else
        print date < 10 ? " #{calendar.ReverseColor(date)} " : "#{calendar.ReverseColor(date)} " if last_day.mday != date
    end
end
puts 
