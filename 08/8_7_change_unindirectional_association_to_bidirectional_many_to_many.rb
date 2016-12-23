#
# 片方向リンク
# Order+------>Customer
#      *      1
# ★OrderはCustomerの情報を参照できるが、
#   CustomerはOrderに対する参照を保持していない
#
# 双方向リンク(many to many)
# Order<------>Customer
#      *      *

require 'set'
class Order
  attr_reader :customers

  def initialize(customer)
    @customers = Set.new
    add_customer(customer)
  end

  # OPTIMIZE: 多対多の実装方法
  def add_customer(customer)
    # HACK: Customer側に関連を追加
    customer.friend_orders.add(self)
    # HACK: 自分側に関連を保持
    @customers.add(customer)
  end

  def remove_customer(customer)
    customer.friend_orders.subtract([self])
    @customers.subtract([customer])
  end

end

class Customer
  attr_accessor :name
  def initialize(name)
    @name = name
    @orders = Set.new
  end

  def friend_orders
    @orders
  end

  # HACK: Order側に処理は委譲。ややこしくなくていいな。
  def add_order(order)
    order.add_customer(self)
  end

  def remove_order(order)
    order.remove_customer(self)
  end

end

require 'test/unit'
class OrderTest < Test::Unit::TestCase
  def test_customer
    c1 = Customer.new("me")
    c2 = Customer.new("you")
    o1 = Order.new(c1)
    o2 = Order.new(c2)

    s0 = Set.new # 空集合
    s1 = Set.new([o1])
    s2 = Set.new([o2])
    s3 = Set.new([o1, o2])
    s4 = Set.new([c1])
    s5 = Set.new([c2])
    s6 = Set.new([c1, c2])

    # 初期状態
    assert_equal s1, c1.friend_orders
    assert_equal s4, o1.customers
    assert_equal s2, c2.friend_orders
    assert_equal s5, o2.customers

    # Order1をCustomer1と関連付け
    o1.add_customer(c1)
    assert_equal s1, c1.friend_orders
    assert_equal s4, o1.customers
    assert_equal s2, c2.friend_orders
    assert_equal s5, o2.customers

    # Order1をCustomer2と関連付け Order1はCustomer1|2と関連がある
    o1.add_customer(c2)
    assert_equal s1, c1.friend_orders
    assert_equal s6, o1.customers
    assert_equal s3, c2.friend_orders
    assert_equal s5, o2.customers

    # Order2をCustomer2と関連付けを削除
    o2.remove_customer(c2)
    assert_equal s1, c1.friend_orders
    assert_equal s6, o1.customers
    assert_equal s1, c2.friend_orders
    assert_equal s0, o2.customers
  end
end

class CustomerTest < Test::Unit::TestCase
  def test_customer
    c1 = Customer.new("me")
    c2 = Customer.new("you")
    o1 = Order.new(c1)
    o2 = Order.new(c2)

    s0 = Set.new # 空集合
    s1 = Set.new([o1])
    s2 = Set.new([o2])
    s3 = Set.new([o1, o2])
    s4 = Set.new([c1])
    s5 = Set.new([c2])
    s6 = Set.new([c1, c2])

    # 初期状態
    assert_equal s1, c1.friend_orders
    assert_equal s4, o1.customers
    assert_equal s2, c2.friend_orders
    assert_equal s5, o2.customers

    # Order1をCustomer1と関連付け
    c1.add_order(o1)
    assert_equal s1, c1.friend_orders
    assert_equal s4, o1.customers
    assert_equal s2, c2.friend_orders
    assert_equal s5, o2.customers

    # Order1をCustomer2と関連付け Order1はCustomer1|2と関連がある
    c2.add_order(o1)
    assert_equal s1, c1.friend_orders
    assert_equal s6, o1.customers
    assert_equal s3, c2.friend_orders
    assert_equal s5, o2.customers

    # Order2をCustomer2と関連付けを削除
    c2.remove_order(o2)
    assert_equal s1, c1.friend_orders
    assert_equal s6, o1.customers
    assert_equal s1, c2.friend_orders
    assert_equal s0, o2.customers
  end
end

