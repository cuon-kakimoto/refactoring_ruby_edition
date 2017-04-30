########################################
# 属性初期化の遅延実行
# [MEMO]
# - initialize時ではなく、アクセス時に属性を初期化する。
# - initializeをフック出来ない場合はこっちでも良いのではないでしょうか？
# - もしくは、必須ではないオブジェクトを作る場合とか(ex. 値オブジェクトの注入)
# - 違う。「属性の初期化を遅延実行したいと思うのは、コードを読みやすくしたいとき」
# - 「属性の初期化を遅延実行すれば、初期化ロジックをメソッド内にカプセル化できる」
########################################

# [BAD]
#class Employee
#  attr_reader :emails, :voice_mails
#
#  def initialize
#    @emails = []
#    @voice_mails = []
#  end
#end

# [GOOD]
class Employee
  def emails
    @emails ||= []
  end

  def voice_mails
    @voice_mails ||= []
  end
end


require 'test/unit'
class EmployeeTest < Test::Unit::TestCase

  def setup
    @employee = Employee.new
  end

  def test_initilaize
    assert_equal [],     @employee.emails
    assert_equal [],     @employee.voice_mails
  end
end
