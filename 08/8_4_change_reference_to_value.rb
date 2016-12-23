# OPTIMIZE: オブジェクトがイミュータブルか、ミュータブルにするかの判断が重要
# イミュータブル: 値オブジェクト
# ミュータブル: 参照オブジェクト
#
class Currency
  attr_reader :code
  # OPTIMIZE: Instances関連は参照オブジェクトのため不要
  # Instances = {}

  def initialize(code)
    # Instances[code] ||= self
    @code = code
  end

  def self.get(code)
    # Instances[code]
  end

  # OPTIMIZE: 値オブジェクトにするために、eql/==/hashをオーバライド
  def eql?(other)
    self == (other)
  end

  def ==(other)
    other.equal?(self) ||
      (other.instance_of?(self.class) &&
       other.code == code)
  end

  def hash
    code.hash
  end
end

require 'test/unit'

class CurrencyTest < Test::Unit::TestCase
  # def test_currency_via_reference
  #   # OPTIMIZE: 参照オブジェクトの場合false
  #   c1 = Currency.new("USD")
  #   c2 = Currency.new("USD")
  #   assert_equal false ,c1 == c2
  #   assert_equal false ,c1.eql?(c2)
  #   # OPTIMIZE: 一致させるには、内部でインスタンスを管理しなければならない。
  #   assert_equal true ,c1 == Currency.get("USD")
  #   assert_equal true ,c1.eql?(Currency.get("USD"))
  # end

  def test_currency_via_value
    c1 = Currency.new("USD")
    c2 = Currency.new("USD")
    assert_equal true ,c1 == c2
    assert_equal true ,c1.eql?(c2)
  end
end
