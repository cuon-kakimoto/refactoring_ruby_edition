require 'test/unit'

class Performance
  # OPTIMIZE: 読み込み属性/書き込み属性をを判断して、attr_*で追加してく
  attr_accessor :name
  attr_writer :wins
  def wins
    @wins.to_i
  end

  # OPTIMIZE: アクセサを定義したので不要にできる
  def initialize
    @data = []
  end

  # HACK: '[index] = value'で使える。paserがよしなにやってくれてるんだろう
  def []=(index,value)
    @data.insert(index, value)
  end

  def [](index)
    @data[index]
  end
end
class ArrayTest < Test::Unit::TestCase
  # OPTIMIZE: Arrayに異なる種類の情報を格納すべきでない。第一要素は人の名前というルールは覚えにくい。
  # オブジェクトを使えば、フィールドとメソッドを伝えることができる
  def test_array
    row = []
    row[0] = "Liverpool"
    row[1] = "15"

    name = row[0]
    wins = row[1].to_i

    assert_equal "Liverpool", name
    assert_equal 15, wins
  end
end

class PerformanceTest < Test::Unit::TestCase
  def test_array
    row = Performance.new
    row[0] = "Liverpool"
    row[1] = "15"

    name = row[0]
    wins = row[1].to_i
    assert_equal "Liverpool", name
    assert_equal 15, wins
  end

  # HACK: しかし、本当に順番が必要な時はどうしたらいいのだろうか。
  # -> 別オブジェクトを作って管理すれば良いのかな。
  def test_performance
    row = Performance.new
    row.name = "Liverpool"
    row.wins = "15"

    assert_equal "Liverpool", row.name
    assert_equal 15, row.wins
  end
end
