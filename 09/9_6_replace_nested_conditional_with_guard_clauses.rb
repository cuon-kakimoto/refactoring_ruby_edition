########################################
# 条件分岐のネストからガード節へ
# [MEMO]
# - ガード節(return if true)のポイントは片方を強調することができる。
# - if-then-else文は同等のウェイトが置かれている。
########################################

# [BAD]
#class Payment
#
#  def initialize(dead, separeted, retired)
#    @dead = dead
#    @separeted = separeted
#    @retired = retired
#  end
#
#  def pay_amount
#    if @dead
#      result = dead_amount
#    else
#      if @separeted
#        result = separeted_amount
#      else
#        if @retired
#          result = retired_amount
#        else
#          result = normal_pay_amount
#        end
#      end
#    end
#    result
#  end
#
#  def dead_amount
#    10
#  end
#
#  def separeted_amount
#    100
#  end
#
#  def retired_amount
#    1000
#  end
#
#  def normal_pay_amount
#    10000
#  end
#end

# [GOOD]
class Payment

  def initialize(dead, separeted, retired)
    @dead = dead
    @separeted = separeted
    @retired = retired
  end

  def pay_amount
    return dead_amount if @dead
    return separeted_amount if @separeted
    return retired_amount if @retired
    return normal_pay_amount
  end

  def dead_amount
    10
  end

  def separeted_amount
    100
  end

  def retired_amount
    1000
  end

  def normal_pay_amount
    10000
  end
end

# [GOOD]
require 'test/unit'

class PaymentTest < Test::Unit::TestCase
  # 初期値はやり方あるよね。。。
  def setup
    @payment1 = Payment.new(true, false, false)
    @payment2 = Payment.new(false, true, false)
    @payment3 = Payment.new(false, false, true)
    @payment4 = Payment.new(false, false, false)
  end

  def test_pay_amount
    assert_equal 10,    @payment1.pay_amount
    assert_equal 100,   @payment2.pay_amount
    assert_equal 1000,  @payment3.pay_amount
    assert_equal 10000, @payment4.pay_amount
  end

end
