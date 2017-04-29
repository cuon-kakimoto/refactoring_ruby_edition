########################################
# 説明用変数の導入
# [MEMO]
# - 複雑な式は、わかりやすい変数名にいれなさい。
# - 一時変数も使いどころですね。
# - でもまずはメソッド抽出を使うこと。他のメソッドからも参照できるようになりますしね。
# - BADはテストケースがよくわからん。
# - メソッドの抽出わかりやすい。メソッドに名前がつけるからいいよね。一時変数はただの無名メソッド的な。
########################################

# [BAD]
# class Item
# 
#   def initialize(quantity, item_price)
#     @quantity = quantity
#     @item_price = item_price
#   end
# 
#   def price
#     @quantity * @item_price -
#       [0, @quantity - 500].max * @item_price * 0.05 +
#       [@quantity * @item_price * 0.1, 100.0].min
#   end
# end

# [GOOD]
#class Item
#
#  def initialize(quantity, item_price)
#    @quantity = quantity
#    @item_price = item_price
#  end
#
#  def price
#    base_price = @quantity * @item_price
#    quantity_discount = [0, @quantity - 500].max * @item_price * 0.05
#    shipping = [@quantity * @item_price * 0.1, 100.0].min
#    base_price - quantity_discount + shipping
#  end
#end

# [メソッドの抽出]
class Item

  def initialize(quantity, item_price)
    @quantity = quantity
    @item_price = item_price
  end

  def price
    base_price - quantity_discount + shipping
  end

  def base_price
    @quantity * @item_price
  end

  def quantity_discount
    [0, @quantity - 500].max * @item_price * 0.05
  end

  def shipping
    [@quantity * @item_price * 0.1, 100.0].min
  end
end


require 'test/unit'

class ItemTest < Test::Unit::TestCase
  def setup
   @item1 = Item.new(10, 1000)
   @item2 = Item.new(10,  100)
  end

  def test_price
    assert_equal 10100, @item1.price
    assert_equal  1100, @item2.price
  end
end
