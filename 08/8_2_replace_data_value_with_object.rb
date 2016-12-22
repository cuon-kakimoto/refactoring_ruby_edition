# OPTIMIZE: 注文した顧客を「文字列」に格納から「オブジェクト」に変更する
# OPTIMIZE: 値オブジェクトに変更することにより、顧客名に加えて、電話番号や住所を保持することができる。
# HACK: しかし、↑のようなデータは参照オブジェクトにすべき。
class Order
  # attr_accessor :customer

  # OPTIMIZE: 引数名をcustomerからcusotmer_nameに変更。
  # 値がオブジェクトではなく、名前であることを明示
  def initialize(customer_name)
    # @customer = customer
    @customer = Customer.new(customer_name)
  end

  # OPTIMIZE: メソッド名をcustomerからcusotmer_nameに変更。
  def customer_name
    @customer.name
  end

  # OPTIMIZE: OrderとCustomerは一対一に対応(Customerは値オブジェクト)。
  # 値オブジェクトは書き変え不能であるべき
  def customer=(value)
    @customer = Customer.new(value)
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
    # orders.select { |order| order.customer == customer }.size
    orders.select { |order| order.customer_name == customer }.size
  end
  # HACK: クラスメソッドをprivate化
  # private_class_method :number_of_orders_for

end


require 'test/unit'

class OrderTest < Test::Unit::TestCase
  def test_order
    o = Order.new("me")
    assert_equal "me", o.customer_name
  end
end

class ClientTest < Test::Unit::TestCase
  def test_order
    orders = [Order.new("me"), Order.new("you")]
    assert_equal 1, Client.number_of_orders_for(orders, "me")
  end
end
