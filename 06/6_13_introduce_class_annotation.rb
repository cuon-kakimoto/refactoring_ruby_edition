########################################
# クラスアノテーションの導入
# [MEMO]
# - こんな手法もあるんだ!だが、railsつかってるならいらん。
# - ただやりかたは知ったほうがいいやつですね。
# - Classクラスでのincludeはやばくない?なにが起きるかわからん。
# - 「実装の手順がごく一般的なので、安全に隠してしまえるようなメソッド」っていうのがポイントだった。
# - 初期化時にそういうパラメータおおいだけで、メソッド名でより説明できていいかかも!
########################################
module CustomInitializers
  # OPTIMIZE: 同クラスに一緒に置くとコードは見づらい。
  # モジュール抽出して、Classに入れ込む
  def hash_initializer(*attribute_names)
  # HACK: def initialize(*args)を動的に生成。この発想はなかった。
  # 任意のキー名リスト(ex. [:author_id, :publisher_id, :isbn]を処理できる
    define_method(:initialize) do |*args|
      data = args.first || {}
      attribute_names.each do |attribute_name|
        instance_variable_set "@#{attribute_name}", data[attribute_name]
      end
    end
  end
end
# HACK: こんなこじ開け方もあるのかー
# class SearchCriteria定義前に行う必要がある。
# もっと最適なタイミングはありそうだが...
# -> railsではやってくれちゃってるから、使う機会はなさそう。。。
Class.send :include, CustomInitializers
class SearchCriteria
  attr_accessor :author_id, :publisher_id, :isbn
  # OPTIMIZE: コード明確化のために、クラスアノテーションを導入する
  # def initialize(hash)
  #   @author_id = hash[:author_id]
  #   @publisher_id = hash[:publisher_id]
  #   @isbn = hash[:isbn]
  # end

  hash_initializer :author_id, :publisher_id, :isbn
end

require 'test/unit'

class SearchCriteriaTest < Test::Unit::TestCase
  def setup
    @search = SearchCriteria.new({
      author_id: 1,
      publisher_id: 2,
      isbn: "123456",
    })
  end
  def test_initialize
    assert_equal 1,        @search.author_id
    assert_equal 2,        @search.publisher_id
    assert_equal "123456", @search.isbn
  end
end
