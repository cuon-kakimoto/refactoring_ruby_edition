########################################
# メソッドの移動
# [MEMO]
# - メソッドやフィールドをどのオブジェクトに管理されるかは、設計でもっとも重要!
# - だってこれが設計だもんな。
# - 自分のクラスのオブジェクトよりも他のオブジェクトを参照してるなら、移す指針。
# - AccountTypeってポリモーフィズムかな?
# - DB設計時にAccountTypeを外部に持つか。自分でもって、外部に作成するか。手段はいろいろ。
# - インスタンス変数の引数にすべきですよね。関数型好きだからって、これはrubyじゃい!
# - コンパイルチェックのない動的言語でテストなしとか死ねる。
# - days_overdrawn以上に何か要るなら、account毎渡せば良い。
# - 別テーブルにすると毎度結合が走るから、カラムからデータを作ったほうが良いかもね。
########################################

# [BAD]
# class Account
#   def initialize(account_type, days_overdrawn)
#     @account_type = account_type
#     @days_overdrawn = days_overdrawn
#   end
# 
#   def overdraft_charge
#     if @account_type.premium?
#       result = 10
#       result += (@days_overdrawn - 7) * 0.85 if @days_overdrawn > 7
#     else
#       @days_overdrawn * 1.75
#     end
#   end
# 
#   def bank_charge
#     result = 4.5
#     result += overdraft_charge if @days_overdrawn > 0
#     result
#   end
# end

# [GOOD]
class Account
  def initialize(account_type, days_overdrawn)
    @account_type = account_type
    @days_overdrawn = days_overdrawn
  end

  def bank_charge
    result = 4.5
    result += @account_type.overdraft_charge(@days_overdrawn)if @days_overdrawn > 0
    result
  end
end

class AccountType
  def premium?
    true
  end

  def overdraft_charge(days_overdrawn)
    if premium?
      result = 10
      result += (days_overdrawn - 7) * 0.85 if days_overdrawn > 7
    else
      days_overdrawn * 1.75
    end
  end
end


# [GOOD]
require 'test/unit'

class AccountTest < Test::Unit::TestCase
  def setup
    @account = Account.new(AccountType.new, 10)
  end

  def test_state
    assert_equal 17.05, @account.bank_charge
  end
end


