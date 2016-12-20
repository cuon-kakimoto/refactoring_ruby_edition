class Person
  # [Pattern] 委譲の削減
  attr_accessor :department

  def initialize(department)
    @department = department
  end

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

# [Base]
# 委譲メソッドが大量になってくるとつらくなってくる。
john = Person.new(Department.new("manager"))
p john.manager #=> manager

# [Pattern]
p john.department.manager #=> manager
