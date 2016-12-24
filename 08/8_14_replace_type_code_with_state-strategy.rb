# OPTIMIZE: 条件分岐を取り除く
#  手段としては以下の3つ
# 「タイプコードからポリモーフィズムへ」 - タイプコードのある箇所がクラスの主要部分の場合に選択
# 「タイプコードからモジュールのextendへ」 - タイプコードに依存しない振る舞い
# 「タイプコードからState/Strategyへ」 - タイプコタイプコードに依存しない振る舞い

require 'forwardable'
class MountainBike
  TIRE_WIDTH_FACTOR = 1
  FRONT_SUSPENSION_FACTOR = 1
  REAR_SUSPENSION_FACTOR = 1

  extend Forwardable

  # OPTIMIZE: type_codeを除去
  # attr_reader :type_code

  # OPTIMIZE: ユーザにクラスを注入させて、処理を委譲
  def_delegators :@bike_type, :off_road_ability, :price

  def initialize(bike_type)
    @bike_type = bike_type
    # set_state_from_hash(params)
  end

  # def type_code=(value)
  #   @type_code = value
  #   # OPTIMIZE: 呼び出し元のクラスを書き換えないようにして、リファクタリングのステップを小さくしている！
  #   @bike_type = case type_code
  #                when :rigid
  #                  RigidMountainBike.new(
  #                    :tire_width => @tire_width,
  #                    :commission => @commission,
  #                    :base_price => @base_price,
  #                  )
  #                when :front_suspension
  #                  FrontSuspensionMountainBike.new(
  #                    :tire_width => @tire_width,
  #                    :front_fork_travel => @front_fork_travel,
  #                    :commission => @commission,
  #                    :base_price => @base_price,
  #                    :front_suspension_price => @front_suspension_price,
  #                  )
  #                when :full_suspension
  #                  FullSuspensionMountainBike.new(
  #                    :tire_width => @tire_width,
  #                    :front_fork_travel => @front_fork_travel,
  #                    :rear_fork_travel => @rear_fork_travel,
  #                    :commission => @commission,
  #                    :base_price => @base_price,
  #                    :front_suspension_price => @front_suspension_price,
  #                    :rear_suspension_price => @rear_suspension_price,
  #                  )
  #                end
  # end

  def add_front_suspension(params)
    # self.type_code = :front_suspension
    @bike_type = FrontSuspensionMountainBike.new(
      @bike_type.upgradable_parameters.merge(params)
    )
    # set_state_from_hash(params)
  end

  def add_rear_suspension(params)
    unless @bike_type.is_a?(FrontSuspensionMountainBike)
      raise "You can't add rear suspension unless you have front suspension"
    end
    # self.type_code = :full_suspension
    @bike_type = FullSuspensionMountainBike.new(
      @bike_type.upgradable_parameters.merge(params)
    )
    # set_state_from_hash(params)
  end

  # OPTIMIZE: off_road_abilityの処理は@bike_typeに委譲
  # def off_road_ability
  #   return @bike_type.off_road_ability if type_code == :rigid
  #   result = @tire_width * TIRE_WIDTH_FACTOR
  #   if type_code == :front_suspension || type_code == :full_suspension
  #     result += @front_fork_travel * FRONT_SUSPENSION_FACTOR
  #   end
  #   if type_code == :full_suspension
  #     result += @rear_fork_travel * REAR_SUSPENSION_FACTOR
  #   end
  #   result
  # end

  # OPTIMIZE: priceの処理は@bike_typeに委譲
  # def price
  #   case type_code
  #   when :rigid
  #     ( 1 + @commission ) * @base_price
  #   when :front_suspension
  #     ( 1 + @commission ) * @base_price + @front_suspension_price
  #   when :full_suspension
  #     ( 1 + @commission ) * @base_price + @front_suspension_price + @rear_suspension_price
  #   end
  # end

  # private
  # OPTIMIZE: インスタンス変数設定コードを取り除く
  # def set_state_from_hash(hash)
  #   @base_price = hash[:base_price] if hash.has_key?(:base_price)
  #   if hash.has_key?(:front_suspension_price)
  #     @front_suspension_price = hash[:front_suspension_price]
  #   end
  #   if hash.has_key?(:rear_suspension_price)
  #     @rear_suspension_price = hash[:rear_suspension_price]
  #   end
  #   if hash.has_key?(:commission)
  #     @commission = hash[:commission]
  #   end
  #   if hash.has_key?(:tire_width)
  #     @tire_width = hash[:tire_width]
  #   end
  #   if hash.has_key?(:front_fork_travel)
  #     @front_fork_travel = hash[:front_fork_travel]
  #   end
  #   if hash.has_key?(:rear_fork_travel)
  #     @rear_fork_travel = hash[:rear_fork_travel]
  #   end
  #   self.type_code = hash[:type_code] if hash.has_key?(:type_code)
  # end
end

class RigidMountainBike
  def initialize(params)
    @tire_width = params[:tire_width]
    @commission = params[:commission]
    @base_price = params[:base_price]
  end

  def off_road_ability
    @tire_width * MountainBike::TIRE_WIDTH_FACTOR
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
      # :type_code => :rigid,
      :tire_width => 2.5,
      :commission => 1000,
      :base_price => 2000,
      )
    )
    @bike2 = MountainBike.new(
      FrontSuspensionMountainBike.new(
      # :type_code => :front_suspension,
      :tire_width => 2.5,
      :front_fork_travel => 3,
      :commission => 1000,
      :base_price => 2000,
      :front_suspension_price => 2000,
      )
    )
    @bike3 = MountainBike.new(
      FullSuspensionMountainBike.new(
      # :type_code => :full_suspension,
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
