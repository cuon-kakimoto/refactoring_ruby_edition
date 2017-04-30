########################################
# タイプコードからポリモーフィズムへ。
# [MEMO]
# - 「タイプのふるまいに影響を与えるタイプコードが使われている」
# - => タイプコードの値1つ1つにクラスをつくる
# - 条件分岐を取り除く。手段としては以下の3つ
# - 1. 「タイプコードからポリモーフィズムへ」
# - => タイプコードのある箇所がクラスの主要部分の場合に選択. rubyのダックタイピングを利用するばよい。これがrubyの長所!!!
# - 2. 「タイプコードからモジュールのextendへ」
# - => タイプコードに依存しない振る舞い. クラスに対してextendすればインスタンス変数がモジュール間で共有できて、単純化される。
# - 3. 「タイプコードからState/Strategyへ」
# - => タイプコードに依存しない振る舞い. インスタンス変数を共有することはできない。
# - rubyの長所: インターフェスを継承したり、実装しなくて良い!
########################################

# [BAD]
# if, case文の条件分岐をしたくない!
class MountainBike
  TIRE_WIDTH_FACTOR = 1
  FRONT_SUSPENSION_FACTOR = 1
  REAR_SUSPENSION_FACTOR = 1

  def initialize(params)
    params.each{ |key, value| instance_variable_set "@#{key}", value }
  end

  def off_road_ability
    result = @tire_width * TIRE_WIDTH_FACTOR
    if @type_code == :front_suspension || @type_code == :full_suspension
      result += @front_fork_travel * FRONT_SUSPENSION_FACTOR
    end
    if @type_code == :full_suspension
      result += @rear_fork_travel * REAR_SUSPENSION_FACTOR
    end
    result
  end

  def price
    case @type_code
    when :rigid
      ( 1 + @commission ) * @base_price
    when :front_suspension
      ( 1 + @commission ) * @base_price + @front_suspension_price
    when :full_suspension
      ( 1 + @commission ) * @base_price + @front_suspension_price + @rear_suspension_price
    end
  end
end

require 'test/unit'
class MountainBikeTest < Test::Unit::TestCase

  def setup
    @bike1 = MountainBike.new(
      :type_code => :rigid,
      :tire_width => 2.5,
      :commission => 1000,
      :base_price => 2000,
    )
    @bike2 = MountainBike.new(
      :type_code => :front_suspension,
      :tire_width => 2.5,
      :front_fork_travel => 3,
      :commission => 1000,
      :base_price => 2000,
      :front_suspension_price => 2000,
    )
    @bike3 = MountainBike.new(
      :type_code => :full_suspension,
      :tire_width => 2.5,
      :front_fork_travel => 3,
      :rear_fork_travel => 3,
      :commission => 1000,
      :base_price => 2000,
      :front_suspension_price => 2000,
      :rear_suspension_price => 2000,
    )
  end

  def test_off_road_ability
    assert_equal 2.5,     @bike1.off_road_ability
    assert_equal 5.5,     @bike2.off_road_ability
    assert_equal 8.5,     @bike3.off_road_ability
  end

  def test_price
    assert_equal 2002000, @bike1.price
    assert_equal 2004000, @bike2.price
    assert_equal 2006000, @bike3.price
  end
end
