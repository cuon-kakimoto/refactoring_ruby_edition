# OPTIMIZE: 制御フラグをbreak文に置き換える
class Guard
  def check_security(people)
    found = false
    people.map do |person|
      # unless found
      #   if person == 'Don'
      #     send_alert
      #     found = true
      #   end
      #   if person == 'John'
      #     send_alert
      #     found = true
      #   end
      # end
      if person == 'Don'
        # HACK: 内部で標準出力(副作用)を利用してるのはまずいな。
        send_alert
        break
      end
      if person == 'John'
        send_alert
        break
      end
    end
  end

  def send_alert
    puts "容疑者発見"
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
    list1: ["容疑者発見", ['Shinji', 'Don', 'John']],
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
