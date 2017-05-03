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



########################################
## Facotryメソッドについて考察
########################################
#[Railsのコードを読む]
#initializeで別クラスのコンストラクタはガシガシ読んでいる。
#また、labmdaをごりごり渡していたり、30行以上のinitalizeなど、結構重そうな処理をしてるクラスもある。
#% actionpack/lib/action_dispatch/routing/mapper.rb
#  結構重いinitialize. 50行ぐらい有り。
#  基本的にinitializeで全部やればいいと思ってしまった。
#内部で自クラスのメソッドを読んでいるのもあった。(反証発見)
#% actionpack/lib/action_dispatch/testing/assertion_response.rb:18:
#  ※ただし、読んでいるメソッドはprivateになっている。
#actionview/lib/action_view/base.rb:197
#  こっちでは、publicになっている。
#
#
#[memo]initialize内でextendしてるクラスを発見
#初めてみたわ。
#% activejob/test/support/integration/jobs_manager.rb
#class JobsManager
#  def initialize(adapter_name)
#    @adapter_name = adapter_name
#    require_relative "adapters/#{adapter_name}"
#    extend "#{adapter_name.camelize}JobsManager".constantize
#  end
#end
#
#Facotryメソッド
#  コンストラクタ名が変わるから、後でgrepする時に漏れが生じる。
#  コードはわかりやすくなるけれども、フレームワークで共通のFacotryメソッドとして規約を作ったほうがうまくいくかな。
#  アプリケーションでファクトリメソッドをcomposeとしても、他からは認識できない。
#  アプリケーションでファクトリメソッドを使うよりは、ファクトリオブジェクトとしてクラス抽出した方がいいかな。
#  もしくは、railsを使っているなら、createを使えばいいじゃん(笑)わざわざ道を外れる必要はない。
#  composeというカッコつけは止めよう。
