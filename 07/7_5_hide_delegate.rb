########################################
# 委譲の隠蔽
# [MEMO]
# - カプセル化。クライアントに不要なものは見せない。クライアントが知りすぎると設計が爆発する。
# - extractクラスでどのような切り出し方にするかは、クライアントがどこまで知るかに関わってくる
########################################

require 'forwardable'

# [BAD]
# class Person
#   attr_accessor :department
# end

# [GOOD]
class Person
  attr_accessor :department
  # OPTIMIZE: [Pattern1]Personに委譲メソッドを作成
  def manager
    department.manager
  end

  # OPTIMIZE: [Pattern2]Personに委譲メソッドを作成
  extend Forwardable
  def_delegator :@department, :manager

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
    # ClientはmanagerのクラスはDepartmentが行っていると知っている->[疎結合]ではないためNG
    # assert_equal "manager", @john.department.manager
    assert_equal "manager", @john.manager
  end
end


