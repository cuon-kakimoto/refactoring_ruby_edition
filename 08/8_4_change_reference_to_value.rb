########################################
# 参照から値。
# [MEMO]
# - オブジェクトがイミュータブルか、ミュータブルにするかの判断が重要
# - イミュータブル: 値オブジェクト(書き換え不能)
# - ミュータブル: 参照オブジェクト(書き換え可能)
# - 参照オブジェクトはインスタンスの管理が求められる(DBなどに保存するとか)
# - 分散/並行システムでは、値オブジェクトが便利。
# - 給与は変更可能。新しい値オブジェクトをつくればよい。
# - 値オブジェクトは、==とeql?メソッドのoverrideが必要。
########################################

########################################
# [BAD]
########################################
class Currency
  attr_reader :code
  Instances = {}

  def initialize(code)
    @code = code
  end

  def self.load_currency
    new("USD").store
  end

  def store
    Instances[code] = self
  end

  def self.get(code)
    Instances[code]
  end
end

########################################
# [GOOD]値オブジェクト
########################################
class Currency
  attr_reader :code

  def initialize(code)
    @code = code
  end

  def eql?(other)
    self == (other)
  end

  def ==(other)
    other.equal?(self) ||
      (other.instance_of?(self.class) &&
       other.code == code)
  end

  # HACK: eql?を定義する時は必要
  def hash
    code.hash
  end
end

require 'test/unit'

class CurrencyTest < Test::Unit::TestCase
  #def test_currency_via_reference
  #  c1 = Currency.new("USD")
  #  c2 = Currency.new("USD")
  #  assert_equal false ,c1 == c2
  #  assert_equal false ,c1.eql?(c2)
  #  # 内部インスタンスを取得しないと一致判定はできない。
  #  assert_equal true , Currency.get("USD") == Currency.get("USD")
  #  assert_equal true , Currency.get("USD").eql?(Currency.get("USD"))
  #end

  def test_currency_via_value
    c1 = Currency.new("USD")
    c2 = Currency.new("USD")
    assert_equal true ,c1 == c2
    assert_equal true ,c1.eql?(c2)
  end
end
