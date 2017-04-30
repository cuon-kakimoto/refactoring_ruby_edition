########################################
# データ値からオブジェクトへ。
# [MEMO]
# - ただのデータだと思っていたら、いろんな作業する必要がある。オブジェクトへ。
# - でも、これもそないに難しいことしていなければ、やる必要もないってやつですね。やり過ぎ注意。
# - 値オブジェクト(書き換え不能、immutalbe)
# - ex. `@customer = Customer.new(value)`
# - 参照オブジェクト(書き換え可能)
# - ex. `@customer ||= Customer.new(value)`
########################################

# [BAD] ※Customerはただの文字列
# class Order
#   attr_accessor :customer
# 
#   def initialize(customer)
#     @customer = customer
#   end
# end
# 
# class Client
#   def self.number_of_orders_for(orders, customer)
#     orders.select { |order| order.customer == customer }.size
#   end
# end

# [GOOD] ※Customerをオブジェクトへ。

# OPTIMIZE: 注文した顧客を「文字列」に格納から「オブジェクト」に変更する
# OPTIMIZE: 値オブジェクトに変更することにより、顧客名に加えて、電話番号や住所を保持することができる。
# HACK: しかし、↑のようなデータは参照オブジェクトにすべき。
class Order

  # OPTIMIZE: 引数名をcustomerからcustomer_nameに変更。
  # 値がオブジェクトではなく、名前であることを明示
  def initialize(customer_name)
    @customer = Customer.new(customer_name)
  end

  # OPTIMIZE: メソッド名をcustomerからcustomer_nameに変更。
  def customer_name
    @customer.name
  end

  # OPTIMIZE: OrderとCustomerは一対一に対応(Customerは値オブジェクト)。
  # 毎度作成してるので、書き換え不能(immutable)
  # 値オブジェクトは書き変え不能であるべき
  # 8-4のeql/==/hashをオーバライドする対応をすれば不要か?
  def customer=(customer_name)
    @customer = Customer.new(customer_name)
  end
end

# OPTIMIZE: Customerを格納するオブジェクトを作成
class Customer
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

class Client

  def self.number_of_orders_for(orders, customer)
    orders.select { |order| order.customer_name == customer }.size
  end
  # HACK: クラスメソッドをprivate化.テストできんのでやらん。
  # private_class_method :number_of_orders_for

end


require 'test/unit'

class ClientTest < Test::Unit::TestCase
  def test_order
    orders = [Order.new("me"), Order.new("you")]
    assert_equal 1, Client.number_of_orders_for(orders, "me")
  end
end
