########################################
# 抽象スーパークラスからモジュールへ
# [MEMO]
# - スーパークラスのインスタンスを明示的に生成するつもりはない。
# - 生成予定のないBaseクラスはmoduleで十分だってことだ。
# - => rubyではabstractクラスは無くて、いとが正しく伝わらないのでmoduleを導入。
# - 選択肢
# - 1. コンストラクタでerror
# - 1. module
# - self included両方のサブクラスにメソッド追加
# - でも、moduleはintializeはするんですね。=> それでも抽象化しないっていう場合に使う。
########################################

# [BAD] Abstractクラス
#class Join
#  def initialize(table, options)
#    @table = table
#    @on = options[:on]
#  end
#
#  def self.joins_for_table(table_name)
#    table_name.to_s
#  end
#
#  def to_sql
#    "#{join_type} JOIN #{@table} ON #{@on}"
#  end
#
#  # これの意図がよくわからん。
#  #def self.inherited(klass)
#  #  klass.class_eval do
#  #    def self.joins_for_table(table_name)
#  #      table_name.to_s
#  #    end
#  #  end
#  #end
#end
#
#class LeftOuterJoin < Join
#  def join_type
#    "LEFT OUTER"
#  end
#end
#
#class InnerJoin < Join
#  def join_type
#    "INNER"
#  end
#end

# [GOOD] module
module Join
  def initialize(table, options)
    @table = table
    @on = options[:on]
  end

  def to_sql
    "#{join_type} JOIN #{@table} ON #{@on}"
  end

  def self.included(mod)
    mod.class_eval do
      def self.joins_for_table(table_name)
        table_name.to_s
      end
    end
  end
end

class LeftOuterJoin
  include Join
  def join_type
    "LEFT OUTER"
  end
end

class InnerJoin
  include Join
  def join_type
    "INNER"
  end
end

require "test/unit"
class JoinTest < Test::Unit::TestCase
  def setup
    @left_outer = LeftOuterJoin.new(
      :equipment_listings,
      :on => "equipment_listings.listing_id = listings.is")
    @inner = InnerJoin.new(
      :equipment_listings,
      :on => "equipment_listings.listing_id = listings.is")
  end

  def test_joins_for_table
    assert_equal "listings", LeftOuterJoin.joins_for_table("listings")
    assert_equal "listings", InnerJoin.joins_for_table("listings")
  end
  def test_to_sql
    assert_equal "LEFT OUTER JOIN equipment_listings ON equipment_listings.listing_id = listings.is", @left_outer.to_sql
    assert_equal "INNER JOIN equipment_listings ON equipment_listings.listing_id = listings.is", @inner.to_sql
  end
end
