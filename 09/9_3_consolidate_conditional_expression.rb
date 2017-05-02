########################################
# 条件式の結合
# [MEMO]
# - 条件式のテストが明確になる
# - メソッドに適切に名前がつけられることが条件
# - メソッド抽出するにしても、それを公開I/Fにするかどうかは別ですよね。。。
# - もしかしたら、# メソッドは別の場所がふさわしいのかもしれないし。
########################################

# [BAD]
#class Benefit
#  def initialize(params)
#    params.each{ |key, value| instance_variable_set "@#{key}", value }
#  end
#
#  def disability_amount
#    # HACK: こういうテストしにくいコードは本当にいけてないよね。
#    return 0 if @seniority < 2
#    return 0 if @months_disabled < 12
#    return 0 if @is_part_time
#    1000
#  end
#end

# [GOOD]
class Benefit
  def initialize(params)
    params.each{ |key, value| instance_variable_set "@#{key}", value }
  end

  def disability_amount
    # OPTIMIZE: シーケンスの条件分はORの結合と同じ
    return 0 if ineligible_for_disability
    1000
  end

  # HACK: これでも、テストコードは変わらないか。値を返すか、true|falseを返すかの違い
  # HACK: オブジェクト指向では条件分岐を取り除いてテストしやすくしなければならないな。
  def ineligible_for_disability
    @seniority < 2 || @months_disabled < 12 || @is_part_time
  end
end

require 'test/unit'

class BenefitTest < Test::Unit::TestCase
  def setup
    @benefit1 = Benefit.new({
      seniority: 1,
      months_disabled: 12,
      is_part_time: true,
    })
    @benefit2 = Benefit.new({
      seniority: 2,
      months_disabled: 12,
      is_part_time: true,
    })
    @benefit3 = Benefit.new({
      seniority: 2,
      months_disabled: 13,
      is_part_time: true,
    })
    @benefit4 = Benefit.new({
      seniority: 2,
      months_disabled: 13,
      is_part_time: false,
    })
  end

  def test_disability_amount
    assert_equal 0,    @benefit1.disability_amount
    assert_equal 0,    @benefit2.disability_amount
    assert_equal 0,    @benefit3.disability_amount
    assert_equal 1000, @benefit4.disability_amount
  end
end
