#FizzBuzz
#1から20までの数をプリントするプログラムを書け。
#ただし3の倍数のときは数の代わりに｢Fizz｣と、5の倍数のときは｢Buzz｣とプリントし、3と5両方の倍数の場合には｢FizzBuzz｣とプリントすること。

[*1..20].map do |num|
    if num % 15 == 0
        puts "FizzBuzz"
    elsif num % 3 == 0
        puts "Fizz"
    elsif num % 5 == 0
        puts "Buzz"
    else
        puts num
    end
end
