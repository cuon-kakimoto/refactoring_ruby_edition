########################################
# 横流しブローカーの除去
# [MEMO]
# - 大量にやりすぎると収拾がつかなくなるというやつですね。
# - でも、判断するのは難しい。
# - また、delegateするのかという飽きがきたらですかね。
########################################
# [BAD]
# class Person
#   attr_accessor :department
#   # OPTIMIZE: [Pattern1]Personに委譲メソッドを作成
#   def manager
#     department.manager
#   end
#
#   # OPTIMIZE: [Pattern2]Personに委譲メソッドを作成
#   extend Forwardable
#   def_delegator :@department, :manager
#
# end

# [GOOD]
class Person
  attr_accessor :department

  def manager
    @department.manager
  end
end

class Department
  attr_reader :manager
  def initialize(manager)
    @manager = manager
  end
end

require 'test/unit'

class PersonTest < Test::Unit::TestCase
  def setup
    @john = Person.new
    @john.department = Department.new("manager")
  end

  def test_state
    assert_equal "manager", @john.department.manager
  end
end


