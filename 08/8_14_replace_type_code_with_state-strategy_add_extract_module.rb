require 'forwardable'
class MountainBike
  TIRE_WIDTH_FACTOR = 1
  FRONT_SUSPENSION_FACTOR = 1
  REAR_SUSPENSION_FACTOR = 1

  extend Forwardable

  def_delegators :@bike_type, :off_road_ability, :price

  def initialize(bike_type)
    @bike_type = bike_type
  end

  def add_front_suspension(params)
    @bike_type = FrontSuspensionMountainBike.new(
      @bike_type.upgradable_parameters.merge(params)
    )
  end

  def add_rear_suspension(params)
    unless @bike_type.is_a?(FrontSuspensionMountainBike)
      raise "You can't add rear suspension unless you have front suspension"
    end
    @bike_type = FullSuspensionMountainBike.new(
      @bike_type.upgradable_parameters.merge(params)
    )
  end
end

# #TODO: モジュールが状態をもつことがイケてない。。。
# 入力と出力が一定にならない。
module DefaultMountainBike
  def default_off_road_ability(bike)
    bike.tire_width * MountainBike::TIRE_WIDTH_FACTOR
  end
end

class RigidMountainBike
  include DefaultMountainBike
  # TODO: 前回のリファクタリングでリーダーを消してるんだけどな。。。
  attr_reader :tire_width
  def initialize(params)
    @tire_width = params[:tire_width]
    @commission = params[:commission]
    @base_price = params[:base_price]
  end

  def off_road_ability
    default_off_road_ability(self)
    # @tire_width * MountainBike::TIRE_WIDTH_FACTOR
  end

  def price
    ( 1 + @commission ) * @base_price
  end

  def upgradable_parameters
    {
      :tire_width => @tire_width,
      :commission => @commission,
      :base_price => @base_price,
    }
  end

end

class FrontSuspensionMountainBike
  def initialize(params)
    @tire_width        = params[:tire_width]
    @front_fork_travel = params[:front_fork_travel]
    @commission             = params[:commission]
    @base_price             = params[:base_price]
    @front_suspension_price = params[:front_suspension_price]
  end

  def off_road_ability
    default_off_road_ability(self)
    @tire_width * MountainBike::TIRE_WIDTH_FACTOR + @front_fork_travel * MountainBike::FRONT_SUSPENSION_FACTOR
  end

  def price
    ( 1 + @commission ) * @base_price + @front_suspension_price
  end

  def upgradable_parameters
    {
      :tire_width => @tire_width,
      :front_fork_travel => @front_fork_travel,
      :commission => @commission,
      :base_price => @base_price,
      :front_suspension_price => @front_suspension_price,
    }
  end
end

class FullSuspensionMountainBike
  def initialize(params)
    @tire_width        = params[:tire_width]
    @front_fork_travel = params[:front_fork_travel]
    @rear_fork_travel  = params[:rear_fork_travel]
    @commission             = params[:commission]
    @base_price             = params[:base_price]
    @front_suspension_price = params[:front_suspension_price]
    @rear_suspension_price  = params[:rear_suspension_price]
  end

  def off_road_ability
    @tire_width * MountainBike::TIRE_WIDTH_FACTOR + @front_fork_travel * MountainBike::FRONT_SUSPENSION_FACTOR + @rear_fork_travel * MountainBike::REAR_SUSPENSION_FACTOR
  end

  def price
    ( 1 + @commission ) * @base_price + @front_suspension_price + @rear_suspension_price
  end

  def upgradable_parameters
    {
      :tire_width => @tire_width,
      :front_fork_travel => @front_fork_travel,
      :rear_fork_travel => @rear_fork_travel,
      :commission => @commission,
      :base_price => @base_price,
      :front_suspension_price => @front_suspension_price,
      :rear_suspension_price => @rear_suspension_price,
    }
  end
end

require 'test/unit'
class MountainBikeTest < Test::Unit::TestCase

  def setup
    @bike1 = MountainBike.new(
      RigidMountainBike.new(
      :tire_width => 2.5,
      :commission => 1000,
      :base_price => 2000,
      )
    )
    @bike2 = MountainBike.new(
      FrontSuspensionMountainBike.new(
      :tire_width => 2.5,
      :front_fork_travel => 3,
      :commission => 1000,
      :base_price => 2000,
      :front_suspension_price => 2000,
      )
    )
    @bike3 = MountainBike.new(
      FullSuspensionMountainBike.new(
      :tire_width => 2.5,
      :front_fork_travel => 3,
      :rear_fork_travel => 3,
      :commission => 1000,
      :base_price => 2000,
      :front_suspension_price => 2000,
      :rear_suspension_price => 2000,
      )
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

  def test_add_front_suspension
    assert_equal 2.5,     @bike1.off_road_ability
    @bike1.add_front_suspension(
      :tire_width => 2.5,
      :front_fork_travel => 3,
      :commission => 1000,
      :base_price => 2000,
      :front_suspension_price => 2000,
    )
    assert_equal 5.5,     @bike1.off_road_ability
    assert_equal 2004000, @bike1.price
  end

  def test_add_rear_suspension
    assert_equal 5.5,     @bike2.off_road_ability
    @bike2.add_rear_suspension(
      :tire_width => 2.5,
      :front_fork_travel => 3,
      :rear_fork_travel => 3,
      :commission => 1000,
      :base_price => 2000,
      :front_suspension_price => 2000,
      :rear_suspension_price => 2000,
    )
    assert_equal 8.5,     @bike2.off_road_ability
    assert_equal 2006000, @bike2.price
  end
end
