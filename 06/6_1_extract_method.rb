########################################
# メソッドの抽出
# [MEMO]
# - IOのテストめんどくさい。。。
# - IOはIO用のクラスが欲しいよね。
# - ローカル変数の再代入。一気にコードの見通しが悪くなる。
# - ローカル変数は使わない。-> query問い合わせにしたほうがよい。
# - ↑使ったとしてもprivateメソッドかな。。。privateは使ってもいいか。影響範囲が狭いので。
# - でも、eachループではなくて、コレクションクロージャーメソッド(inject)を使えば一時保存用の変数もいらなくなる!!!
# - メソッドの先頭でoutstandingを初期化するのもいいけど、使用するメソッドの近くで初期化すると見通しがよくなる。
# - でも、そうなると、print_details の引数に渡しても良い気がするけど。長さの問題かな。
# - 戻り値は1つにする。
# - 2つ以上の戻り値を返すことはメソッド抽出して１つにしたい
# - ↑どうしても返したいならそれはオブジェクトにすればよいではないか。
########################################

# [BAD]
# class Customer
#
#   def initialize(name)
#     @name = name
#   end
#
#   def print_owing(amount)
#     outstanding = 0.0
#     # バナーを出力(print banner)
#     puts "****************************************"
#     puts "**** Cutomer Owes ***********************"
#     puts "****************************************"
#
#     # 勘定を計算(calculate outstanding)
#     @orders.each do |order|
#       outstanding += order.amount
#     end
#
#   end
# end

# [GOOD]
# amountの値が変化することも考慮している。
class Customer

  def initialize(name)
    @name = name
  end

  def print_owing(previoust_amount)
    outstanding = 0.0

    print_banner
    outstanding = calculate_outstanding(previoust_amount * 1.2)
    print_details outstanding
  end

  def print_banner
    puts "****************************************"
    puts "**** Cutomer Owes ***********************"
    puts "****************************************"
  end

  def print_details(outstanding)
    puts "name: #{@name}"
    puts "amount: #{outstanding}"
  end

  def calculate_outstanding(initial_value)
    @orders.inject(initial_value) { |result, order| result + order.amount }
  end
end

# TODO?: IOのテストはパス
require 'test/unit'

class CustomerTest < Test::Unit::TestCase
end
