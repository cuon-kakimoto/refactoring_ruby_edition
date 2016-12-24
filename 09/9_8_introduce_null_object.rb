# OPTIMIZE: 例えばひとりの人についての情報を表示する時、20くらいのインスタンス変数を持ち、それらがnull許可と鳴ると、情報の出力はとても複雑になる。
# nilチェックの条件分岐を除外する

# OPTIMIZE: Nullオブジェクトは常に変わらない->Singleton
require 'singleton'
module DefaultInitialize
  def initialize(params = {})
    params.each{ |key, value| instance_variable_set "@#{key}", value }
  end
end

class MissingCustomer
  include Singleton
  # OPTIMIZE: nullクラスかそうでないかをチェックする
  def missing?
    true
  end

  def name
    'occupant'
  end

  # OPTIMIZE: メソッドチェインで呼ばれるものは新しいNullオブジェクトを追加
  def history
    PaymentHistory.new_null
  end

  def plan
    BillingPlan.new_null
  end

end

class NullBillingPlan
  include Singleton
  def name
    'basic'
  end
end

class NullPaymentHistory
  include Singleton
  def weeks_delinquent_in_last_year
    0
  end
end

class Site
  include DefaultInitialize
  attr_reader :customer

  def customer
    @customer || Customer.new_missing
  end
end

class Customer
  include DefaultInitialize
  attr_reader :name, :plan, :history

  def missing?
    false
  end

  def plan_name
    @plan.name
  end

  # OPTIMIZE: ファクトリ生成。クライアントはNullクラスについての知識を持たない。
  def self.new_missing
    # MissingCustomer.new
    MissingCustomer.instance
  end
end

class BillingPlan
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def self.basic
    BillingPlan.new('basic')
  end

  def self.advance
    BillingPlan.new('advance')
  end

  def self.new_null
    NullBillingPlan.instance
  end

end

class PaymentHistory

  def self.new_null
    NullPaymentHistory.instance
  end

  def weeks_delinquent_in_last_year
    10
  end
end

require 'test/unit'
class ClientTest < Test::Unit::TestCase
  # HACK: test_*がテスト実行対象
  def setup
    # HACK: Customerが複数のクラスインスタンスを持ってて良いんだな。
    # railsでいうと、belongs_toでコンポーネントを作成してる的な。
    @customer = Customer.new({
      name: "me",
      plan: BillingPlan.advance,
      history: PaymentHistory.new,
    })
    @site1 = Site.new({customer: @customer})
    @site2 = Site.new
  end

  def test_client
    # Customer
    customer = @site1.customer
    assert_equal false, customer.missing?
    name = customer.missing? ? 'occupant' : customer.name
    plan = customer.missing? ? BillingPlan.basic : customer.plan
    weeks_delinquent = customer.missing? ? 0 : customer.history.weeks_delinquent_in_last_year
    assert_equal 'me', name
    assert_equal 'advance', plan.name
    assert_equal 10, weeks_delinquent

    # Cusomter(nil)
    customer = @site2.customer
    assert_equal true, customer.missing?
    name = customer.missing? ? 'occupant' : customer.name
    plan = customer.missing? ? BillingPlan.basic : customer.plan
    weeks_delinquent = customer.missing? ? 0 : customer.history.weeks_delinquent_in_last_year
    assert_equal 'occupant', name
    assert_equal 'basic', plan.name
    assert_equal 0, weeks_delinquent

    # =============================
    # Nullオブジェクト導入後のテスト
    # - 条件分岐がなくなるのは素敵。
    # =============================
    # Customer
    customer = @site1.customer
    assert_equal false, customer.missing?
    assert_equal 'me', customer.name
    assert_equal 'advance', customer.plan.name
    assert_equal 10, customer.history.weeks_delinquent_in_last_year

    # NullCustomer
    customer = @site2.customer
    assert_equal 'occupant', customer.name
    assert_equal 'basic', customer.plan.name
    assert_equal 0, customer.history.weeks_delinquent_in_last_year

    # Singleton
    assert_equal PaymentHistory.new_null, PaymentHistory.new_null
    assert_equal BillingPlan.new_null, BillingPlan.new_null
    assert_equal Customer.new_missing, Customer.new_missing
  end
end


