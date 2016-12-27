# [BAD]
# def discount(input_val, quantity, year_to_date)
#   input_val -= 2 if input_val > 50
#   input_val -= 1 if quantity > 100
#   input_val -= 4 if year_to_date > 10000
#   input_val
# end
# [GOOD]
# def discount(input_val, quantity, year_to_date)
#   result = inputval
#   result -= 2 if input_val > 50
#   result -= 1 if quantity > 100
#   result -= 4 if year_to_date > 10000
#   result
# end

# HACK: Rubyは値渡しを使っている。
x = 5
def triple(arg)
  arg = arg * 3
  puts "arg in triple: #{arg}"
end
triple x                   #=> arg in triple: 15
puts "x after triple #{x}" #=> x after triple 5

# HACK: オブジェクト参照は値渡しされているため、メソッド本体のスコープを離れると代入の効果は反映されない。
class Ledger
  attr_reader :balance

  def initialize(balance)
    @balance = balance
  end

  def add(arg)
    @balance += arg
  end

end

class Product
  def self.add_price_by_updating(ledger, price)
    ledger.add(price)
    puts "ledger in add_price_by_updating; #{ledger.balance}"
  end

  def self.add_price_by_replacing(ledger, price)
    # HACK: オブジェクト参照に代入
    ledger = Ledger.new(ledger.balance + price)
    puts "ledger in add_price_by_replacing; #{ledger.balance}"
  end
end

l1 = Ledger.new(0)
Product.add_price_by_updating(l1, 5)
puts "l1 after add price_by_updating: #{l1.balance}"
# HACK: 内部でオブジェクト参照に代入しているが、値渡しのためスコープを抜けると反映されない。
l2 = Ledger.new(0)
Product.add_price_by_replacing(l2, 5)
puts "l2 after add price_by_replacing: #{l2.balance}"
