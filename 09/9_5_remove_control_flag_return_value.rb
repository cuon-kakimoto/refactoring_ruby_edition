########################################
# 制御フラグの除去
# - 制御フラグ情報に加えて、結果情報を返すreturn
# [MEMO]
# - peopleループがpersonになるんですね。この感覚はなかった。
########################################

# [BAD]
#class Guard
#  def check_security(people)
#    found = ""
#    # HACK: foundは結果を知らせているので、ループをメソッドにする。
#    people.each do |person|
#      if found == ""
#        if person == 'Don'
#          send_alert
#          found = 'Don'
#        end
#        if person == 'John'
#          send_alert
#          found = 'John'
#        end
#      end
#    end
#    more_alert(found)
#  end
#
#  def send_alert
#    puts "容疑者発見"
#  end
#
#  def more_alert(found)
#    puts found
#  end
#end

# [GOOD]
class Guard
  def check_security(people)
    found = found_miscreant(people)
    more_alert(found)
  end

  # 制御フラグも取り除く、これ分かりやすいかな？？？
  def found_miscreant(people)
    people.each do |person|
      if person == 'Don'
        send_alert
        return 'Don'
      end
      if person == 'John'
        send_alert
        return 'John'
      end
    end
    ""
  end

  def send_alert
    puts "容疑者発見"
  end

  def more_alert(found)
    puts found
  end
end

# HACK: 標準出力に対するテストコードを書ける。
# $stdoutのグローバル変数を切り替えているのがポイントでした!
require "stringio"
require 'test/unit'

class GuardTest < Test::Unit::TestCase
  def setup
    @gurad = Guard.new
    $stdout = StringIO.new
  end

  # HACK: データ駆動テストを実践!!!
  # 失敗すると、tagが表示されてわかりよい!
  data(
    # tag: [ expected, target ]
    list1: ["容疑者発見\nDon", ['Shinji', 'Don', 'John']],
    list2: ["", ['Shinji', 'Haruna']],
  )
  def test_check_security_any(data)
    # HACK: この分離が出来るのはarrayの機能みたい。perl風だなー。
    expected, target = data
    @gurad.check_security(target)
    assert_equal expected, $stdout.string.chomp
  end

  def teardown
    $stdout = STDOUT
  end
end
