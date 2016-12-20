require 'forwardable'

class Person
  attr_accessor :department

  # OPTIMIZE: [Pattern2]Personに委譲メソッドを作成
  extend Forwardable
  def_delegator :@department, :manager


  # OPTIMIZE: [Pattern1]Personに委譲メソッドを作成
  #def manager
  #  department.manager
  #end
end

class Department
  attr_reader :manager

  def initialize(manager)
    @manager = manager
  end
end

# [Base]
# ClientはmanagerのクラスはDepartmentが行っていると知っている->[疎結合]のためNG
john = Person.new
john.department = Department.new("manager")
p john.department.manager #=> manager

# [Pattern1]
p john.manager #=> manager

# [Pattern2]
p john.manager #=> manager

