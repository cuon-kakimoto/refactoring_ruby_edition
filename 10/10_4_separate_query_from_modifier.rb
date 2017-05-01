########################################
# 問い合わせメソッドと更新メソッドを分離
# [MEMO]
# - 副作用のあるメソッドは更新するだけにすべし。
########################################

# [BAD]
#class Guard
#  def check_security(people)
#    found = found_miscreant(people)
#  end
#
#  def found_miscreant(people)
#    people.each do |person|
#      if person == 'Don'
#        send_alert
#        return "Don"
#      end
#      if person == 'John'
#        send_alert
#        return "John"
#      end
#    end
#    ""
#  end
#
#  def send_alert
#    puts "容疑者発見"
#  end
#
#end

# [GOOD]
class Guard
  def check_security(people)
    send_alert_if_miscreant_in(people)
    found = found_person(people)
  end

  # OPTIMIZE: 値を返すとともにオブジェクトの状態に変更を加えるメソッド
  # send_alertでオブジェクトの状態が切り替わることを想定(今回は標準出力)
  # def found_miscreant(people)
  #   people.each do |person|
  #     if person == 'Don'
  #       send_alert
  #       # OPTIMIZE: 一度内部呼び出しを挟むことでリファクタリングがしやすくなる
  #       found_person(people)
  #       # return "Don"
  #     end
  #     if person == 'John'
  #       send_alert
  #       return "John"
  #     end
  #   end
  #   ""
  # end

  # OPTIMIZE: 更新メソッドは問い合わせメソッドを利用するように置き換える
  def send_alert_if_miscreant_in(people)
    send_alert unless found_person(people).empty?
  end

  # OPTIMIZE: 問い合わせメソッドは副作用を伴わずに更新メソッドと同じ値を返す
  def found_person(people)
    people.each do |person|
      return "Don" if person == 'Don'
      return "John" if person == 'John'
    end
    ""
  end

  def send_alert
    puts "容疑者発見"
  end
end

require "stringio"
require 'test/unit'

class GuardTest < Test::Unit::TestCase
  def setup
    @gurad = Guard.new
    $stdout = StringIO.new
  end

  data(
    # tag: [ expected, rtn, target ]
    list1: ["容疑者発見", "Don", ['Shinji', 'Don', 'John']],
    list2: ["",           "",    ['Shinji', 'Haruna']],
  )
  def test_check_security_any(data)
    expected, rtn, target = data
    @gurad.check_security(target)
    assert_equal expected, $stdout.string.chomp
    assert_equal rtn, @gurad.check_security(target)
  end

  def teardown
    $stdout = STDOUT
  end
end
