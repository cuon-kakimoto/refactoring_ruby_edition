# 8_12_replace_type_code_with_polymorphism.rbと同じ。
# HACK: モジュールのincludeわかりやすいし、使いやすいな。

module MountainBike
  TIRE_WIDTH_FACTOR = 1
  FRONT_SUSPENSION_FACTOR = 1
  REAR_SUSPENSION_FACTOR = 1

  def initialize(params)
    params.each{ |key, value| instance_variable_set "@#{key}", value }
  end
end

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

  def setup
    @bike1 = RigidMountainBike.new(
      :tire_width => 2.5,
      :commission => 1000,
      :base_price => 2000,
    )
    @bike2 = FrontSuspensionMountainBike.new(
      :tire_width => 2.5,
      :front_fork_travel => 3,
      :commission => 1000,
      :base_price => 2000,
      :front_suspension_price => 2000,
    )
    @bike3 = FullSuspensionMountainBike.new(
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
