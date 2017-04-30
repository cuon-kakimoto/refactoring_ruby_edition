########################################
# フィールドの移動
# [MEMO]
########################################

# [BAD]
# class Account
#   def initialize(interest_rate)
#     @interest_rate = interest_rate
#   end
# 
#   def interest_for_amount_days(amount,days)
#     @interest_rate * amount * days / 365
#   end
# end

# [GOOD]
class Account
  def initialize(account_type)
    @account_type = account_type
  end

  def interest_for_amount_days(amount,days)
    @account_type.interest_rate * amount * days / 365
  end

  # HACK: 自己カプセル化フィールドをつかうとステップが楽になる。
  # これなら、もうAccountTypeしか使ってないから移動できるね。
  def interest_rate
    @account_type.interest_rate
  end
end

class AccountType
  attr_accessor :interest_rate

  def initialize(interest_rate)
    @interest_rate = interest_rate
  end
end


# [GOOD]
require 'test/unit'

class AccountTest < Test::Unit::TestCase
  def setup
    @account_type = AccountType.new(1000)
    @account = Account.new(@account_type)
  end

  def test_state
    assert_equal 27397, @account.interest_for_amount_days(1000, 10)
  end
end


