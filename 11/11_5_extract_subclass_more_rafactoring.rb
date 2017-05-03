########################################
# サブクラスの抽出
# [MEMO]
# さらなる最適化の方針:
# - JobItemに対してサブクラスを抽出するPartsItem
# - さらにJobItemはインスタンス生成されないので、抽象クラスからモジュールへを使う。
# - TODO
########################################

# [misc]
class Employee
  attr_reader :rate
  def initialize(rate)
    @rate = rate
  end
end

# [GOOD]
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

class PartsItem < JobItem

  def initialize(unit_price, quantity)
    super
  end

  def unit_price
    @unit_price
  end

protected

  def labor?
    false
  end
end

class LaborItem < JobItem
  attr_reader :employee

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
    @job_item2 = JobItem.new(100, 50)
  end

  def total_price
    assert_equal 5000, @job_item2.total_price
  end
  def test_unit_price
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

class PartsItemTest < Test::Unit::TestCase
  def setup
    @employee = Employee.new(2000)
    @parts_item = PartsItem.new(100, 50)
  end

  def total_price
    assert_equal 5000, @parts_item.total_price
  end
  def test_unit_price
    assert_equal  100, @parts_item.unit_price
  end
end

