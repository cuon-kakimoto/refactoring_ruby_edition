########################################
# 引数から別々のメソッドへ。
# [MEMO]
# - わかりやすさはturn_on=>読むように書く！
#   Switch.turn_on > Switch.set_state(true)
# - ファクトリメソッドは、「ダックタイピング」できないっす。
# - 「それほど多くのサブクラスが新しくつくられるとは予想されないので明示的に別々のメソッド」
# - サブクラスが多く出来たら、利点は無いかもね。
########################################

# [BAD]
class Employee
  ENGINEER = 0
  SALESPERSON = 1
  MANAGER = 2

  # OPTIMIZE: ファクトリメソッド
  # 明示的に別のメソッドを作るインターフェスを用意する
  def self.create(type)
    case type
    when ENGINEER
      # Engineer.new
      self.create_enginner
    when SALESPERSON
      # Salesperson.new
      self.create_salesperson
    when MANAGER
      # Manager.new
      self.create_manager
    else
      raise ArgumentError, "Incorrect type code value"
    end
  end
end

# [GOOD]
class Employee

  # # OPTIMIZE: ファクトリメソッド
  # # 明示的に別のメソッドを作るインターフェスを用意する
  # def self.create(type)
  # end

  def self.create_enginner
    Engineer.new
  end

  def self.create_salesperson
    Salesperson.new
  end

  def self.create_manager
    Manager.new
  end
end

class Engineer; end
class Salesperson; end
class Manager; end

require 'test/unit'

class EmployeeTest < Test::Unit::TestCase
  def setup
  end

  def test_create
    # Before
    #@employee = Employee.create(Employee::ENGINEER)
    #assert_equal Engineer, @employee.class
    #@employee = Employee.create(Employee::SALESPERSON)
    #assert_equal Salesperson, @employee.class
    #@employee = Employee.create(Employee::MANAGER)
    #assert_equal Manager, @employee.class

    # After
    # OPTIMIZE: 呼び出し側でtype_codeによって作成するオブジェクトを切り替えるよりも、
    # インターフェスを利用して作成した方が分かりやすいか。
    @employee = Employee.create_enginner
    assert_equal Engineer, @employee.class
    @employee = Employee.create_salesperson
    assert_equal Salesperson, @employee.class
    @employee = Employee.create_manager
    assert_equal Manager, @employee.class
  end
end
