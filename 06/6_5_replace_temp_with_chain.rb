########################################
# 一時変数からチェインへ。
# = 1つのオブジェクトの表現能力を高めることができる。
# [MEMO]
# - サンプルが全てですね。rspecとかはまさにこれで、いわゆるrubyっぽい書き方か。
# [BAD]
# mock = Mock.new
# mock.hoge
# mock.fuga
# [GOOD]
# mock = Mock.new
# mock.hoge.fuag
#
# 使い所は？
# 一時変数を削除して、保守性を上げる。
#
# - チェイニング出来るようにしたいメソッドからはselfを返すように書き換える。
# - どこかのgatewayでself返したけどそれでよかったんですね。
########################################

# [BAD]
class Select

  def options
    @options ||=[]
  end

  def add_option(arg)
    options << arg
  end
end

# [GOOD]
class Select

  def options
    @options ||=[]
  end

  def self.with_option(option)
    select = self.new
    select.options << option
    select
  end

  # HACK:自然なIFとしてチェイン出来るようにメソッド名を修正
  # def add_option(arg)
  def and(arg)
    options << arg
    self
  end
end

require 'test/unit'

class SelectTest < Test::Unit::TestCase
  # def setup
  #  @select = Select.new
  # end

  # def test_price
  #   @select.add_option(1999)
  #   @select.add_option(2000)
  #   @select.add_option(2001)
  #   @select.add_option(2002)
  #   assert_equal [1999, 2000, 2001, 2002], @select.options
  # end
  def setup
   @select = Select.with_option(1999)
  end

  def test_price
    @select.and(2000).and(2001).and(2002)
    assert_equal [1999, 2000, 2001, 2002], @select.options
  end
end
