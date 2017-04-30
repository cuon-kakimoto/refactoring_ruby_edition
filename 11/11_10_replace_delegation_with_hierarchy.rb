########################################
# 委譲から継承へ
# [MEMO]
# - オブジェクトが書き換えられないなら、データをコピーすればいいだけなので簡単
# - オブジェクトが書き換えるなら、リファクタは諦める
########################################

# [BAD]
#require 'forwardable'
#class Employee
#  extend Forwardable
#  def_delegators :@person, :name, :name=
#
#  def initialize
#    @person = Person.new
#  end
#
#  def to_s
#    "Emp: #{@person.last_name}"
#  end
#end
#
#class Person
#  attr_accessor :name
#
#  def last_name
#    @name.split(' ').last
#  end
#end

# [GOOD]
# HACK: module内でインスタンス変数使うのアリのようですね。
# accessorを追加するのもOKか。状態フィールドが追加される。
module Person
  attr_accessor :name

  def last_name
    @name.split(' ').last
  end
end

class Employee
  include Person

  def to_s
    "Emp: #{last_name}"
  end
end


require 'test/unit'

class EmployeeTest < Test::Unit::TestCase
  def setup
    @employee = Employee.new
    @employee.name = "shinji kakimoto"
  end

  def test_to_s
    assert_equal "shinji kakimoto", @employee.name
    assert_equal "Emp: kakimoto", @employee.to_s
  end
end
