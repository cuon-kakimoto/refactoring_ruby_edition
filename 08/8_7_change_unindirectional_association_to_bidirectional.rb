#
# 片方向リンク
# Order+------>Customer
#      *      1
# ★OrderはCustomerの情報を参照できるが、
#   CustomerはOrderに対する参照を保持していない
#
# 双方向リンク
# Order<------>Customer
#      *      1
# ★CustomerもOrderに対する参照を保持する
# ★railsで言うと、こうなるはず
#   Customer has_many Order
#   Order belong_to Customer

require 'set'
class Order
  # OPTIMIZE: アクセサのオーバライド
  # attr_accessor :customer
  attr_reader :customer

  def initialize(customer)
    @customer = customer
  end

  def customer=(value)
    # 自分の保持している元のCustomerへリンク削除を依頼
    customer.friend_orders.subtract([self]) unless customer.nil?
    # 新しいCustomerの情報を保持
    @customer = value
    # 新しいCustomerへリンク追加
    customer.friend_orders.add(self) unless customer.nil?
  end
end

class Customer
  attr_accessor :name
  # OPTIMIZE: CustomerはOrderを複数持つことができるため、CustomerでOrderを管理する
  # OPTIMIZE: 重複を許可しないため、集合で管理する
  def initialize(name)
    @name = name
    @orders = Set.new
  end


  def friend_orders
    # Orderがリンクを更新したときのみ使われる
    # #<Set: {#<Order:0x007f9e8f179618 @customer=#<Customer:0x007f9e8f17a090 @name="me", @orders=#<Set: {...}>>>}>
    @orders
  end

  # OPTIMIZE: Customer側からOrderを追加
  def add_order(order)
    order.customer = self
  end
end

require 'test/unit'
class OrderTest < Test::Unit::TestCase
  def test_order
    c = Customer.new("me")
    o = Order.new(c)
    assert_equal "me", o.customer.name
  end

  def test_customer
    c1 = Customer.new("me")
    c2 = Customer.new("you")

    o1 = Order.new(c1)
    o2 = Order.new(nil)
    s0 = Set.new # 空集合
    s1 = Set.new([o1])
    s2 = Set.new([o1, o2])

    assert_equal "me", o1.customer.name
    assert_equal s0, c1.friend_orders

    # OPTIMIZE: Order毎に異なるCustomerを保持していて、Customer側は関連するOrderのリンクを保持ししている。
    # Order1をCustomer1と関連付け
    o1.customer = c1
    assert_equal "me", o1.customer.name
    assert_equal s1, c1.friend_orders

    # Order1をCustomer2と関連付け -> Customer1の関連付けは削除される
    o1.customer = c2
    assert_equal s0, c1.friend_orders
    assert_equal "you", o1.customer.name
    assert_equal s1, c2.friend_orders

    # Order2をCustomer2と関連付け-> Cusomter2は{Order1,Order2}を持つ
    o2.customer = c2
    assert_equal s2, c2.friend_orders
    assert_equal "you", o1.customer.name
    assert_equal "you", o2.customer.name
    assert_equal s2, c2.friend_orders

    # Order2とCustomer2の関連付けを削除-> Cusomter2は{Order1}を持つ
    o2.customer = nil
    assert_equal s1, c2.friend_orders
    assert_equal "you", o1.customer.name
    assert_equal nil, o2.customer&.name
    assert_equal s1, c2.friend_orders
  end
end

class CustomerTest < Test::Unit::TestCase
  def test_customer
    c1 = Customer.new("me")
    o1 = Order.new(nil)
    o2 = Order.new(nil)
    s1 = Set.new([o1])
    s2 = Set.new([o1, o2])

    c1.add_order(o1)
    assert_equal "me", o1.customer.name
    assert_equal s1, c1.friend_orders

    c1.add_order(o2)
    assert_equal "me", o1.customer.name
    assert_equal "me", o2.customer.name
    assert_equal s2, c1.friend_orders
  end
end

