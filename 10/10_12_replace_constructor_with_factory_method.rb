########################################
# コンストラクタからファクトリメソッドへ。
# [MEMO]
# - オブジェクトを作成する時に単なる構築以上のことをしたい。
# - => コンストラクタを取り除いて、ファクトリメソッドを作る
# - まさにそうかもしれん。注目!!!
# - 使い所: 「作成したオブジェクトの種類を決めるために、条件分岐を使っている場合」
# - これは確かにFactoryにしたらいいな。オブジェクトをカプセル化できるもんな。
# - 問題はinitializeでどこまで含めるべきかということですな。
# - 今回使用した理由:
# - 1. 構築ロジックを複数の箇所で実行しなければならない場合 => コードが散らばるのを防ぐ(DRY!)
# - 2. カプセル化。将来このロジックに対する変更ニーズに簡単に対応できる
#```
#class Some
#
#  def initialize(param)
#    @param = param
#  end
#
#  def compose
#    # あっちこっちからデータを取ってきて組み立てる(@param)のデータも使う
#    @composed_data = ... too long code and using @param...
#  end
#
#  def extract_data
#    @composed_data.data
#  end
#end
#
## Someクラスはメソッドcomposeをコールした後に、データを取得することが出来る。
## ただし、composeのメソッドはめちゃめちゃ長い。
## この場合、initializeでcomposeをコールするのが良いか。
## composeをファクトリメソッドにしてしまうのが良いか?
#[In Client]
#Some.new(param).compose.extract_data # 現状のコードの動作
#Some.new(param).extract_data         # initalizeに寄せる
#Some.compose(param).extract_data     # composeメソッドに寄せる
#
## initalizeで書く処理はどこまでなら許されるものですかね？
## 色んなデータを取ってくる処理をinitializeに入れることを懸念してます。
## なので、単純なsetよりも重い処理をしているので、明示的にファクトリメソッドにする。
## =>しかし、Factoryした上に内部データを使っているので、「使用」と「生成」が分離できていない。
## => initializeでデータを作ったほうが良いかもしれん。
## ただ、ここでは、「ファクトリメソッド」なのでいいかもしれん「ファクトリオブジェクト」ほどではない。
#```
########################################

# [Misc]
class Product
  def initialize(base_price)
    @base_price = base_price
  end

  # OPTIMIZE: ファクトリメソッドに抽出
  def self.create(base_price, imported=false)
    if imported
      ImportedProduct.new(base_price)
    else
      if base_price > 100
        LuxuryProduct.new(base_price)
      else
        Product.new(base_price)
      end
    end
  end
end

class ImportedProduct < Product
  def initialize(base_price)
    @base_price = base_price
  end
end

class LuxuryProduct < Product
  def initialize(base_price)
    @base_price = base_price
  end
end

# [BAD]
# class ProductController
#   attr_accessor :base_price, :imported
#   attr_reader :product
# 
#   def create
#     @product = if imported
#                  ImportedProduct.new(base_price)
#                else
#                  if base_price > 100
#                    LuxuryProduct.new(base_price)
#                  else
#                    Product.new(base_price)
#                  end
#                end
#   end
# end

# [GOOO]
class ProductController
  attr_accessor :base_price, :imported
  attr_reader :product

  def create
    @product = Product.create(base_price, imported)
  end
end


# [GOOD]
require 'test/unit'

class ProductControllerTest < Test::Unit::TestCase
  def setup
   @product_controller = ProductController.new
  end

  def test_imported_product
    @product_controller.imported = true
    @product_controller.create
    assert_equal ImportedProduct, @product_controller.product.class
  end

  def test_luxury_product
    @product_controller.imported = false
    @product_controller.base_price = 1000
    @product_controller.create
    assert_equal LuxuryProduct, @product_controller.product.class
  end

  def test_product
    @product_controller.imported = false
    @product_controller.base_price = 100
    @product_controller.create
    assert_equal Product, @product_controller.product.class
  end
end
