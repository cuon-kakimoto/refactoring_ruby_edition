class Item
  attr_accessor :base_price, :tax_rate

  def initialize(base_price, tax_rate)
    setup(base_price, tax_rate)
  end

  # OPTIMIZE: セッターメソッドをコンストラクタで使用すると、初期化とは異なる動作をすることがあるので、直接アクセスを使うほうが良い。
  def setup(base_price, tax_rate)
    @base_price = base_price
    @tax_rate = tax_rate
  end

  def raise_base_price_by(percent)
    self.base_price = base_price * ( 1 + percent/100.0)
  end

  def total
    base_price * ( 1 + tax_rate )
  end

  # OPTIMIZE: サブクラスで変数アクセスをオーバライドしたくなったため、間接アクセスに切り替え
  # HACK: 直接アクセスはコードが読みやすいため、必要になるまで直接アクセスを使えばよい。
  # def initialize(base_price, tax_rate)
  #   @base_price = base_price
  #   @tax_rate = tax_rate
  # end

  # def raise_base_price_by(percent)
  #   @base_price = @base_price * (1 + percent/100.0)
  # end

  # def total
  #   @base_price * (1 + @tax_rate)
  # end
end

class ImportedItem < Item
  attr_reader :import_duty

  def initialize(base_price, tax_rate, import_duty)
    super(base_price, tax_rate)
    @import_duty = import_duty
  end

  # OPTIMIZE: Itemの振る舞いを変えること無く、tax_rateをオーバライド出来ている。
  def tax_rate
    super + import_duty
  end
end

require 'test/unit'

# TODO: 継承のテスト方法は、「オブジェクト指向実践ガイド」を再度読みたい
class ItemTest < Test::Unit::TestCase
  def test_raise_base_price_by
    i = Item.new(100, 0.05)
    assert_equal 105, i.raise_base_price_by(5)
  end

  def test_total
    i = Item.new(100, 0.05)
    assert_equal 105, i.total
  end
end

class ItemTest < Test::Unit::TestCase
  def test_tax_rate
    i = ImportedItem.new(100, 0.05, 0.05)
    assert_equal 0.1, i.tax_rate
  end

  # TODO: 小数点計算なので誤差が発生
  #def test_raise_base_price_by
  #  i = ImportedItem.new(100, 0.05, 0.05)
  #  assert_equal 110, i.raise_base_price_by(5)
  #end

  #def test_total
  #  i = ImportedItem.new(100, 0.05, 0.05)
  #  assert_equal 110, i.total
  #end
end
