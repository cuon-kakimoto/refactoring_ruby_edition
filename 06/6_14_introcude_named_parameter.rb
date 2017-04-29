########################################
# 名前付き引数の導入
# [MEMO]
# - 他のオブジェクトの挙動を調べなくて済むように、IFを作る
# - これでPJの導入コストが下がるよね。
# - 一部だけ名前付き引数を導入したいなら末尾へ。{}が不要になるので。
# - でも。筆者はclass_anotationのほうが好きな模様
########################################
class SearchCriteria
  attr_accessor :author_id, :publisher_id, :isbn
  def initialize(params)
    @author_id = params[:author_id]
    @publisher_id = params[:publisher_id]
    @isbn = params[:isbn]
  end

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
