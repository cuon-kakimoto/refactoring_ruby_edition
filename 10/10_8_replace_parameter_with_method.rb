########################################
# 引数からメソッドへ
# [MEMO]
# - むむ、引数をどんどん取り除いていってる。
# - 内部の引数がなくなった。。。
# - どんどんメソッド化されていった。これの使いどきを知りたいリファクタリングですね。
# - 最終的に、すべてのメソッドで引数がなくなった。。。
# - 「メソッドが引数として渡される値を他の手段で手に入れられるならそうすべき」
# - 長い引数リストはわかりにくい。
########################################

# [BAD]
#class Item
#  def initialize(quantity, item_price)
#    @quantity = quantity
#    @item_price = item_price
#  end
#
#  def price
#    base_price = @quantity * @item_price
#    level_of_discount = 1
#    level_of_discount = 2 if @quantity > 100
#    discounted_price(base_price, level_of_discount)
#  end
#
#  def discounted_price(base_price, level_of_discount)
#    return base_price * 0.1 if level_of_discount == 2
#    base_price * 0.05
#  end
#end

# [GOOD]
class Item
  def initialize(quantity, item_price)
    @quantity = quantity
    @item_price = item_price
  end

  def price
    # discounted_price
    return base_price * 0.1 if discount_level == 2
    base_price * 0.05
  end

  # OPTIMIZE: メソッドのインライン化。priceでコールしてるだけなので、いらんなー。
  # def discounted_price
  # end

  # HACK: インスタンス変数は引数に渡しません。
  # というか引数で渡せてAPIを公開してると、かなり柔軟に使いすぎませんか？
  # 引数で内部を後悔しないというカプセル化ですね。
  def discount_level
    return 2 if @quantity > 100
    return 1
  end

  def base_price
    @quantity * @item_price
  end

end

require 'test/unit'

class ItemTest < Test::Unit::TestCase
  def setup
   @item1 = Item.new(1000, 10)
   @item2 = Item.new(100,  10)
  end

  def test_price
    assert_equal 1000, @item1.price
    assert_equal   50, @item2.price
  end
end
