########################################
# 名前付き引数の除去
# [MEMO]
# - 呼び出されるメソッドが複雑になるよ。。。
# - オプション引数に名前付き引数を導入してもoptions以上の名付けは出来ないでしょ？
# - ↑これ以上の名前があるなら、きちんと引数にしよう
#
# サンプル的には、
#  def self.find(hash={})としたときが[BAD]
########################################

# [GOOD]
module AssertValidKeys
  def assert_valid_keys(*valid_keys)
    unknown_keys = keys - [valid_keys].flatten
    if unknown_keys.any?
      raise(ArgumentError, "Unknown key(s): #{unknown_keys.join(",")}")
    end
  end
end

# OPTIMIZE: こういうのすごいよ。ほんとに。
Hash.send(:include, AssertValidKeys)
class Books
  def self.find(selector, hash={})
    hash.assert_valid_keys :conditions, :joins

    hash[:joins] ||= []
    hash[:conditions] ||= ""
    sql = ["SELECT * FROM books"]
    hash[:joins].each do |join_table|
      sql << "LEFT OUTER JOIN #{join_table} ON"
      sql << "books.#{join_table.to_s.chop}_id"
      sql << " = #{join_table}.id"
    end
    sql << "where #{hash[:conditions]}" unless hash[:conditions].empty?
    sql << "LIMIT 1" if selector == :first
    # テスト用にsqlを返すだけ
    sql.join(" ")
  end
end

require 'test/unit'

class BooksTest < Test::Unit::TestCase
  # def test_find
  #   assert_equal "SELECT * FROM books", Books.find(:all)
  #   assert_equal "SELECT * FROM books where title like '%Voodoo Economics'", Books.find(:all, "title like '%Voodoo Economics'")
  #   assert_equal "SELECT * FROM books LEFT OUTER JOIN authors ON books.author_id  = authors.id where authore.name = 'Jenny James'", Books.find(:all, "authore.name = 'Jenny James'", :authors)
  #   assert_equal "SELECT * FROM books LEFT OUTER JOIN authors ON books.author_id  = authors.id where authore.name = 'Jenny James' LIMIT 1", Books.find(:first, "authore.name = 'Jenny James'", :authors)
  # end
  def test_find
    assert_equal "SELECT * FROM books", Books.find(:all)
    assert_equal "SELECT * FROM books where title like '%Voodoo Economics'", Books.find(:all, conditions: "title like '%Voodoo Economics'")
    assert_equal "SELECT * FROM books LEFT OUTER JOIN authors ON books.author_id  = authors.id where authore.name = 'Jenny James'", Books.find(:all, conditions: "authore.name = 'Jenny James'", joins: [:authors])
    assert_equal "SELECT * FROM books LEFT OUTER JOIN authors ON books.author_id  = authors.id where authore.name = 'Jenny James' LIMIT 1", Books.find(:first, conditions: "authore.name = 'Jenny James'", joins: [:authors])
  end
end
