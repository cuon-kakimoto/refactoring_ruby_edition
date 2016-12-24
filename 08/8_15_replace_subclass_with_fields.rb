# OPTIMIZE: 定数を保持しているだけのクラスをフィールドに移す
# 1. ファクトリメソッドを用意する(create_female/create_male)
# 2. スーパクラスのコンストラクタにフィールドを用意する(@female, @code)
# 3. 既存のコンストラクタを変更(super(true, 'F'))
# 3. ファクトリメソッド内のコンストラクタをインライン化(Person.new(true, 'F'))
# 4. テストする
# 5. フィールドを用意する、テストする...
class Person

  def initialize(female, code)
    @female = female
    @code = code
  end

  # TODO: こういう書き方をするだけでいいんですね・・・条件分岐必要なし。
  def female?
    @female
  end

  def code
    @code
  end

  def self.create_female
    # Female.new
    Person.new(true, 'F')
  end

  def self.create_male
    # Male.new
    Person.new(false, 'M')
  end
end

# class Female < Person
# 
#   def initialize
#     super(true, 'F')
#   end
# 
#   def female?
#     true
#   end
# 
#   def code
#     'F'
#   end
# end
# 
# class Male < Person
# 
#   def initialize
#     super(false, 'M')
#   end
# 
#   def female?
#     false
#   end
# 
#   def code
#     'M'
#   end
# end

require 'test/unit'

class PersonTest < Test::Unit::TestCase
  def test_female
    bree = Person.create_female
    assert_equal true, bree.female?
    assert_equal 'F', bree.code
  end

  def test_male
    bob = Person.create_male
    assert_equal false, bob.female?
    assert_equal 'M', bob.code
  end
end
