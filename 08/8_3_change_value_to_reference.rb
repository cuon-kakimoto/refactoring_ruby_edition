########################################
# 値から参照へ。
# [MEMO]
# - 先ほどの続きから。
# - 参照オブジェクトは、顧客や口座など。個々のオブジェクトは実世界のひとつのオブジェクトを表す
# - 値オブジェクトは、日付や金額などで、データ値によって定義される。コピーがあっても構わない。
# - railsなら参照オブジェクトはDBに保存されてないとまずい気がします。
# - [BAD]はCustomerは値オブジェクト
# - =>同一顧客で扱おうとしても生成されるインスタンスが異なるため、扱えない。
# - =>参照オブジェクトにして顧客名毎に１つしか無いようにする。
########################################

# [misc]
class Client
  def self.number_of_orders_for(orders, customer)
    orders.select { |order| order.customer_name == customer }.size
  end
end

########################################
# [BAD]
########################################
#class Order
#  def initialize(customer_name)
#    @customer = Customer.new(customer_name)
#  end
#
#  def customer_name
#    @customer.name
#  end
#
#  def customer=(customer_name)
#    @customer = Customer.new(customer_name)
#  end
#end
#
#class Customer
#  attr_reader :name
#
#  def initialize(name)
#    @name = name
#  end
#end
#
#require 'test/unit'
#
#class ClientTest < Test::Unit::TestCase
#  def test_order
#    orders = [Order.new("me"), Order.new("you")]
#    assert_equal 1, Client.number_of_orders_for(orders, "me")
#  end
#end

########################################
# [GOOD]
########################################
class Order
  def initialize(customer_name)
    @customer = Customer.with_name(customer_name)
  end

  def customer_name
    @customer.name
  end

  def customer=(customer_name)
    @customer = Customer.with_name(customer_name)
  end
end

class Customer
  attr_reader :name
  # OPTIMIZE: Customerクラスをアクセスポイントに設定。本来は別オブジェクトにしたほうが良さげ。
  Instances = {}

  def initialize(name)
    @name = name
  end

  # HACK: 自己インスタンスを作成して、storeメソッドを呼び出し
  def self.load_customers
    new("you").store
    new("me").store
  end

  # HACK: nameをkeyにインスタンス自身を格納する=>これかっちょいいな。
  def store
    Instances[name] = self
  end


  # OPTIMIZE: Factoryメソッドを定義する
  # def self.create(name)
  #   Instances[name]
  # end
  # OPTIMIZE: 既存のCustomerを返すのでcreateは不一致。メソッド名を変更. =>Factoryはしてないもんね。
  def self.with_name(name)
    Instances[name]
  end

end
require 'test/unit'

class OrderTest < Test::Unit::TestCase
  def setup
    Customer.load_customers
  end

  def test_order
    o = Order.new("me")
    assert_equal "me", o.customer_name
    o.customer = "you"
    assert_equal "you", o.customer_name
  end
end

class ClientTest < Test::Unit::TestCase
  def setup
    Customer.load_customers
  end

  def test_order
    orders = [Order.new("me"), Order.new("you")]
    assert_equal 1, Client.number_of_orders_for(orders, "me")
  end
end
