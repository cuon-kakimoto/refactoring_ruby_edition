########################################
# メソッドのパラメータ化
# [MEMO]
# - メソッドをまとめてしまうって感じですね。
# - 理想はこれ？公開メソッドだけを読めばなにをしてるかが分かるのが理想だな！！！
########################################

# [BAD]
#class Employee
#  attr_accessor :salary
#
#  def ten_persent_raise
#    @salary *= 1.1
#  end
#
#  def five_persent_raise
#    @salary *= 1.05
#  end
#
#  def base_charge
#    result = [last_usage, 100].min * 0.03
#    if last_usage > 100
#      result += ([last_usage, 200].min - 100) * 0.05
#    end
#
#    if last_usage > 200
#      result += (last_usage - 200) * 0.07
#    end
#
#    result
#  end
#
#  def last_usage
#    100
#  end
#end

# [GOOD]
class Employee
  attr_accessor :salary

  # OPTIMIZE: メソッド的には不要
  def ten_persent_raise
    raise(0.1)
  end

  def five_persent_raise
    raise(0.05)
  end

  def raise(factor)
    @salary *= (1 + factor)
  end


  # HACK: このメソッドは圧倒的にわかりやすくなったな。
  # 公開メソッドだけを読めばなにをしてるかが分かるのが理想だな！！！
  def base_charge
    result = (usage_in_range 0..100) * 0.03
    result += (usage_in_range 100..200) * 0.05
    result += (usage_in_range 200..last_usage) * 0.07
    result
  end

  def usage_in_range(range)
    if last_usage > range.begin
      [last_usage, range.end].min - range.begin
    else
      0
    end
  end

  def last_usage
    100
  end
end

require 'test/unit'
class EmployeeTest < Test::Unit::TestCase
  def setup
    @employee = Employee.new
    @employee.salary = 1000
  end

  def test_raise
    assert_equal 1100, @employee.ten_persent_raise
    assert_equal 1155, @employee.five_persent_raise
    assert_equal 3, @employee.base_charge
  end
end
