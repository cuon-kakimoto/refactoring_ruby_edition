########################################
# タイプコードからポリモーフィズムへ。
# - 1. 「タイプコードからポリモーフィズムへ」
# [MEMO]
# - まさにMountainBikeのメイン処理をmodule化してるなー。
# - => initialize処理がmodule内にあるからな。
# - <module MountainBike>
# - <- RigidMountainBike, FrontSuspensionMountainBike, FullSuspensionMountainBike
# - こんなクラス構成になる。ただ3以上になるときつい気がするけど。
# - とりうるcodeが10,20もいくと、これはきついっすね。
########################################

# OPTIMIZE: Rubyのダックタイプを使うためモジュールに変更
# class MountainBike
module MountainBike
  TIRE_WIDTH_FACTOR = 1
  FRONT_SUSPENSION_FACTOR = 1
  REAR_SUSPENSION_FACTOR = 1

  # HACK: module内でinitializeメソッドを用意するのってありなんだな。
  # modules自体は作成できないけど、クラスの生成をオーバライドできる
  def initialize(params)
    params.each{ |key, value| instance_variable_set "@#{key}", value }
  end

  # OPTIMIZE: 各クラスに移動したため不要
  # def off_road_ability
  # end

  # def price
  # end
end

# OPTIMIZE: タイプごとにクラスを作成して、ひとつひとつメソッドを移動していく
class RigidMountainBike
  include MountainBike

  def off_road_ability
    @tire_width * TIRE_WIDTH_FACTOR
  end

  def price
    ( 1 + @commission ) * @base_price
  end
end

class FrontSuspensionMountainBike
  include MountainBike

  def off_road_ability
    @tire_width * TIRE_WIDTH_FACTOR + @front_fork_travel * FRONT_SUSPENSION_FACTOR
  end

  def price
    ( 1 + @commission ) * @base_price + @front_suspension_price
  end
end

class FullSuspensionMountainBike
  include MountainBike

  def off_road_ability
    @tire_width * TIRE_WIDTH_FACTOR + @front_fork_travel * FRONT_SUSPENSION_FACTOR + @rear_fork_travel * REAR_SUSPENSION_FACTOR
  end

  def price
    ( 1 + @commission ) * @base_price + @front_suspension_price + @rear_suspension_price
  end
end

require 'test/unit'
class MountainBikeTest < Test::Unit::TestCase

  # HACK: ひとつのクラスでタイプコードに分けた処理を新規クラスを作成して条件分岐をなくす。
  # でも、オブジェクト作成時はオーナーがどうしても選ぶ必要がある!?->yes
  # 代替手段はFacotryに委譲して、ownerは使うだけにする。
  def setup
    @bike1 = RigidMountainBike.new(
      # :type_code => :rigid,
      :tire_width => 2.5,
      :commission => 1000,
      :base_price => 2000,
    )
    @bike2 = FrontSuspensionMountainBike.new(
      # :type_code => :front_suspension,
      :tire_width => 2.5,
      :front_fork_travel => 3,
      :commission => 1000,
      :base_price => 2000,
      :front_suspension_price => 2000,
    )
    @bike3 = FullSuspensionMountainBike.new(
      # :type_code => :full_suspension,
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
