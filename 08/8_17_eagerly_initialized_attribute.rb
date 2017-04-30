########################################
# 属性初期化の先行実行
# [MEMO]
# - 本当に時と場合によりますね。。。
# - こういう問題はチームとしてどちらにするかを話し合う。
########################################

# [GOOD]
#class Employee
#  def emails
#    @emails ||= []
#  end
#
#  def voice_mails
#    @voice_mails ||= []
#  end
#end

# [BAD]
class Employee
  attr_reader :emails, :voice_mails

  def initialize
    @emails = []
    @voice_mails = []
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
