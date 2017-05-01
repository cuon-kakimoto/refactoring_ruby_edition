########################################
# 引数オブジェクトの導入
# [MEMO]
# - まとめてひとつの意味のあるオブジェクを作る(代金オブジェクト)
# - attr_accessorでなんでも公開しちゃだめよね。これはもろにメソッド定義なんだから!!!
########################################

# [BAD]
#class Account
#  def initialize
#    @charges = []
#  end
#
#  def add_charge(base_price, tax_rate, imported)
#    total = base_price + base_price * tax_rate
#    total += base_price * 0.1 if imported
#    @charges << total
#  end
#
#  def total_charge
#    @charges.inject(0) { |total, charge| total + charge }
#  end
#end

# [GOOD]
class Account
  def initialize
    @charges = []
  end

  def add_charge(charge)
    # HACK: 引数オブジェクトに続いてChargeオブジェクトに代金計算コードを移す
    #total = charge.base_price + charge.base_price * charge.tax_rate
    #total += charge.base_price * 0.1 if charge.imported
    @charges << charge.total
  end

  def total_charge
    @charges.inject(0) { |total, charge| total + charge }
  end
end

# HACK: イミュータブル?書き換え不能なの？？？readerの間違いかな？
class Charge
  # HACK: この引数美しいなーーーー。
  # ゲッターを取り除いてよりカプセル化
  # attr_accessor :base_price, :tax_rate, :imported

  def initialize(base_price, tax_rate, imported)
    @base_price = base_price
    @tax_rate = tax_rate
    @imported = imported
  end

  def total
    total = @base_price + @base_price * @tax_rate
    total += @base_price * 0.1 if @imported
    total
  end
end

require 'test/unit'

class AccountTest < Test::Unit::TestCase
  def setup
   @account = Account.new
   @account.add_charge(Charge.new( 5,  0.1, true))
   @account.add_charge(Charge.new(12, 0.125, false))
  end

  def test_price
    assert_equal 19.5, @account.total_charge
  end
end
