########################################
# サブクラスの抽出
# [MEMO]
# - ひとつのオブジェクトに含まれる複数のデータをメソッドに渡している時に検討する。
# - [欠点]: オブジェクトを渡すため、依存関係ができる。
# - 呼び出し元が複数の自分のデータを渡してる時はリファクタリングですね。
# - 「ポリモーフィックな定数メソッド」: こんな HACK が
# - 各実装(ここではクラス)が異なる固定値を返すメソッド。
# - 案件でやってはいるけど、名前付けを知ることは意味がある。
# - 初めてproctedを見た
########################################

# [misc]
class Employee
  attr_reader :rate
  def initialize(rate)
    @rate = rate
  end
end

# [BAD]
#class JobItem
#  attr_reader :quantity, :employee
#
#  def initialize(unit_price, quantity, is_labor, employee)
#    @unit_price = unit_price
#    @quantity = quantity
#    @is_labor = is_labor
#    @employee = employee
#  end
#
#  # unit_priceが動的に変わるのね。
#  def total_price
#    unit_price * @quantity
#  end
#
#  def unit_price
#    labor? ? @employee.rate : @unit_price
#  end
#
#  def labor?
#    @is_labor
#  end
#end

# [GOOD]
# さらなる最適化の方針:
# - JobItemに対してサブクラスを抽出するPartsItem
# - さらにJobItemはインスタンス生成されないので、抽象クラスからモジュールへを使う。
class JobItem
  attr_reader :quantity, :unit_price

  def initialize(unit_price, quantity)
    @unit_price = unit_price
    @quantity = quantity
  end

  def total_price
    unit_price * @quantity
  end

protected

  def labor?
    false
  end
end
class LaborItem < JobItem
  attr_reader :employee

  # HACK: highchartでこんな感じのことがしたかった。。。
  def initialize(quantity, employee)
    super(0, quantity)
    @employee = employee
  end

  def unit_price
    @employee.rate
  end

protected

  def labor?
    true
  end
end

require 'test/unit'
class JobItemTest < Test::Unit::TestCase
  def setup
    @employee = Employee.new(2000)
    # @job_item1 = JobItem.new(100, 10, true, @employee)
    @job_item2 = JobItem.new(100, 50)
  end

  def total_price
    # assert_equal 1000, @job_item1.total_price
    assert_equal 5000, @job_item2.total_price
  end
  def test_unit_price
    # assert_equal 2000, @job_item1.unit_price
    assert_equal  100, @job_item2.unit_price
  end
end

class LaborItemTest < Test::Unit::TestCase
  def setup
    @employee = Employee.new(2000)
    @labor_item1 = LaborItem.new(10, @employee)
  end

  def total_price
    assert_equal 1000, @labor_item1.total_price
  end
  def test_unit_price
    assert_equal 2000, @labor_item1.unit_price
  end
end
