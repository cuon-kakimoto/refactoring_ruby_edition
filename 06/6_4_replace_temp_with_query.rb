########################################
# 一時変数から問い合わせメソッドへ。
# [MEMO]
# - 一時変数は使われているメソッドのコンテキストの中でしか参照できないので、メソッド長大化の原因になる。
########################################

# [BAD]
#class Item
#
#  def initialize(quantity, item_price)
#    @quantity = quantity
#    @item_price = item_price
#  end
#
#  def price
#    base_price = @quantity * @item_price
#    if base_price > 1000
#      discount_factor = 0.95
#    else
#      discount_factor = 0.98
#    end
#    base_price * discount_factor
#  end
#end

# [GOOD]
class Item

  def initialize(quantity, item_price)
    @quantity = quantity
    @item_price = item_price
  end

  def price
    base_price * discount_factor
  end

  def base_price
    @quantity * @item_price
  end

  def discount_factor
    base_price > 1000 ? 0.95 : 0.98
  end
end

require 'test/unit'

class ItemTest < Test::Unit::TestCase
  def setup
   @item1 = Item.new(10, 1000)
   @item2 = Item.new(10,  100)
  end

  def test_price
    assert_equal 9500, @item1.price
    assert_equal  980, @item2.price
  end
end
