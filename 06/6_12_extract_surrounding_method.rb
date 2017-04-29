########################################
# サンドウィッチメソッドの抽出
# [MEMO]
# - 重複部分がメソッドの中頃にあるならば、blockで解決できる。
# - templateメソッドパターンを使うことも出来るけど、継承階層が出来るので避ける。
# - 継承を避けるrubyの機能があるなら、つかっていこう。
# - yieldってy(x)なだけじゃん。
# - 「ビジネスロジックと反復処理を分離」これすごいっすね。
# - 流動的要素はビジネスロジックなので、それを別に扱おうとしているぞ！！！
########################################
require 'date'

class Person
  # HACK: 自己参照的な一対多の関係
  # 母親は複数子をもつ
  # fieldでパラメータを定義するんだな。
  attr_reader :mother, :children, :name

  def initialize(name, date_of_birth, date_of_death=nil, mother=nil)
    @name, @mother = name, mother
    @date_of_birth, @date_of_death = date_of_birth, date_of_death
    @children = []
    @mother.add_child(self) if @mother
  end

  def add_child(child)
    @children << child
  end

  # OPTIMIZE: 再帰処理をなくす。呼び出し元がブロックを渡して、ロジックを組み込む
  # OPTIMIZE: ビジネスロジックと反復処理を分離して、メンテンナスをしやすくする
  def number_of_living_descendants
    # HACK: ブロック: { |ブロック変数| 処理 }
    # 通常のメソッド呼び出しは、メソッド側で定義されたコードしか利用できない
    # ブロック付きメソッド呼び出しは、呼び出す側から別のコード(ブロック)を挿入することができる。-> 高階関数を渡しているようなイメージだな。
    count_descendants_matching{ |descendant| descendant.alive? }
    # children.reduce(0) do |count, child|
    #   count += 1 if child.alive?
    #   count + child.number_of_living_descendants
    # end
  end

  def number_of_descendants_named(name)
    count_descendants_matching{ |descendant| descendant.name == name }
    # children.reduce(0) do |count, child|
    #   count += 1 if child.name == name
    #   count + child.number_of_descendants_named(name)
    # end
  end

  # HACK: こういう変換処理をapplication側で用意すればデータベースがnilでも問題ない?
  # データ的には、nilを許可しないほうが流れがよめないか。。?
  def alive?
    @date_of_death.nil?
  end

protected
  # OPTIMIZE: ロジックを呼び出し元に渡させることで、条件によって数え上げるだけの関数になってる!!
  def count_descendants_matching(&block)
    children.reduce(0) do |count, child|
      # HACK: 呼び出し側(number_of_*)で定義されたコード(ブロック)が挿入される。
      # そして、childをブロック変数に使用。
      # HACK: ここでブロックが展開されて、割り当てられると考えたほうがよいな
      # 関数yield(関数y(child))をコールしてるだけじゃん!!!yはblockで与えれられた関数
      count += 1 if yield child
      count + child.count_descendants_matching(&block)
    end
  end
end

require 'test/unit'

class PersonTest < Test::Unit::TestCase
  def setup
   @fumi = Person.new("fumi", Date.new(1930,8,13))
   @shihoko = Person.new("shihoko", Date.new(1950,8,13),nil, @fumi)
   @shinji = Person.new("shinji", Date.new(1988,9,14), nil, @shihoko)
   @akira = Person.new("akira", Date.new(1990,2,27), nil, @shihoko)
   @rokky = Person.new("rokky", Date.new(1988,9,14), Date.new(2000,9,14), @shihoko)
  end

  def test_number_of_living_descendants
    assert_equal 3, @fumi.number_of_living_descendants
  end

  def test_number_of_descendants_named
    assert_equal 1, @fumi.number_of_descendants_named("shinji")
  end
end
