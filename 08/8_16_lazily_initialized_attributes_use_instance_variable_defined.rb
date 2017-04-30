########################################
# 属性初期化の遅延実行
# [MEMO]
# - instance_variable_definedを使った例。
########################################

# [BAD]
#class Employee
#  attr_accessor :id, :assistant
#  def initialize
#    @id = 1
#    @assistant = Employee.find_by_boss_id(self.id)
#  end
#
#  # HACK: これはnilが返る可能性があるので使えない。
#  #def assistant
#  #  @assistant ||= Employee.find_by_boss_id(self.id)
#  #end
#
#  def self.find_by_boss_id(id)
#    nil
#  end
#end

# [GOOD]
class Employee
  attr_accessor :id, :assistant
  def initialize
    @id = 1
  end

  # HACK: これはnilが返る可能性があるので使えない。
  def assistant
    unless instance_variable_defined? :@assistant
      @assistant ||= Employee.find_by_boss_id(self.id)
    end
    @assistant
  end

  def self.find_by_boss_id(id)
    nil
  end
end


require 'test/unit'
class EmployeeTest < Test::Unit::TestCase

  def setup
    @employee = Employee.new
  end

  def test_initilaize
    assert_equal nil,     @employee.assistant
  end
end
