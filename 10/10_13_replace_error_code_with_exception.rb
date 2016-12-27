require 'test/unit'
########################################
# 呼び出し元が呼び出し前にエラー条件をチェックする
########################################
require 'test/unit/assertions'
class Account1
  # TODO: assert使うにはこうするしか無い？
  include Test::Unit::Assertions
  def initialize(balance)
    @balance = balance
  end

  # def withdraw(amount)
  #   return -1 if amount > @balance
  #   @balance -= amount
  #   return 0
  # end

  # OPTIMIZE: can_withdrawを使用した上で使うことを想定しているため、定義上例外
  def withdraw(amount)
    assert("amount too large") { amount <= @balance }
    # OPTIMIZE: プログラマのエラーのため、assertinoの使用に変更
    # raise ArgumentError.new if amount > @balance
    @balance -= amount
  end

  def can_withdraw?(amount)
    return false if amount > @balance
    return true
  end
end

class Account1Test < Test::Unit::TestCase
  def setup
    @account = Account1.new(1000)
  end
  def test_withdraw
    # OPTIMIZE: 呼び出し元のリターンコードの使用を削除
    # if @account.withdraw(5000) == -1
    #   @code = :error
    # else
    #   @code = :success
    # end
    if !@account.can_withdraw?(5000)
      @code = :error
    else
      @code = :success
    end
    assert_equal :error, @code
    # {}形式で書くとエラーになった。
    # assert_raise ArgumentError do
    #   @account.withdraw(5000)
    # end
  end
end


########################################
# 呼び出し元が呼び出し前にエラー条件をチェックする
########################################
class Account2
  def initialize(balance)
    @balance = balance
  end

  def withdraw(amount)
    raise BalanceError.new if amount > @balance
    @balance -= amount
  end

  def can_withdraw?(amount)
    return false if amount > @balance
    return true
  end
end

class Account2Test < Test::Unit::TestCase
  def setup
    @account = Account2.new(1000)
  end
  def test_withdraw
    begin
      @account.withdraw(5000)
      @code = :success
    rescue BalanceError
      @code = :error
    end
    assert_equal :error, @code
  end
end
class BalanceError < StandardError; end

