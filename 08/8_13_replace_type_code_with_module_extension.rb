########################################
# タイプコードからポリモーフィズムへ。
# - 2. 「タイプコードからモジュールのextendへ」
# [MEMO]
# HACK: extendとincludeの違い
# include: インスタンス化するとモジュールで定義されたメソッドを扱えるようになる. でもClassMethodも定義できる。
# extend: モジュールで定義されているメソッドを特異メソッドとして扱えるようになる
# -> ここでは、extendで[動的]に役割を切り替えているのが重要か。
# あ！特異メソッドとクラスメソッドは違うわ!!!特異メソッドは、インスタンスのクラスメソッドだわ。
#
# - ただし、extendはインスタンスを作った後に、type_codeが変わってしまうと対応できなくなりますよ。
# - moduleがextendされるか、includeされるかはどうやって見極めるのだ？？？
# - extend module: 内部にインスタンス変数がある。=> 特異メソッドとして扱える。
# - include module: 内部にインスタンス変数がない。
# - クライアントがクラスを渡したほうが、Factoryにも委譲出来る可能性があるので、良いね。
# - ★生成と使用を分離。
########################################

class MountainBike
  TIRE_WIDTH_FACTOR = 1
  FRONT_SUSPENSION_FACTOR = 1
  REAR_SUSPENSION_FACTOR = 1

  attr_reader :type_code

  def initialize(params)
    # OPTIMIZE: writerを使うから、この形では記述できない
    # params.each{ |key, value| instance_variable_set "@#{key}", value }
    # OPTIMIZE: self.type_codeでモジュールを切り替え
    # self.type_code          = params[:type_code]
    @tire_width             = params[:tire_width]
    @front_fork_travel      = params[:front_fork_travel]
    @rear_fork_travel       = params[:rear_fork_travel]
    @commission             = params[:commission]
    @base_price             = params[:base_price]
    @front_suspension_price = params[:front_suspension_price]
    @rear_suspension_price  = params[:rear_suspension_price]
  end

  # OPTIMIZE: ユーザに依存性を注入させるように変更. こんな書き方が!!!!
  def type_code=(mod)
    extend(mod)
  end
  # HACK: 内部でextendする方法, ただのcodeを渡すかクラスを渡すかの違い。
  # def type_code=(value)
  #   @type_code = value
  #   case type_code
  #     when :rigid
  #       extend(RigidMountainBike)
  #     when :front_suspension
  #       extend(FrontSuspensionMountainBike)
  #     when :full_suspension
  #       extend(FullSuspensionMountainBike)
  #   end
  # end

  # デフォルト挙動は、RigidMountainBike
  def off_road_ability
    @tire_width * MountainBike::TIRE_WIDTH_FACTOR
  end

  def price
    ( 1 + @commission ) * @base_price
  end
end

module FrontSuspensionMountainBike
  def off_road_ability
    @tire_width * MountainBike::TIRE_WIDTH_FACTOR + @front_fork_travel * MountainBike::FRONT_SUSPENSION_FACTOR
  end

  def price
    ( 1 + @commission ) * @base_price + @front_suspension_price
  end
end

module FullSuspensionMountainBike
  def off_road_ability
    @tire_width * MountainBike::TIRE_WIDTH_FACTOR + @front_fork_travel * MountainBike::FRONT_SUSPENSION_FACTOR + @rear_fork_travel * MountainBike::REAR_SUSPENSION_FACTOR
  end

  def price
    ( 1 + @commission ) * @base_price + @front_suspension_price + @rear_suspension_price
  end
end

require 'test/unit'
class MountainBikeTest < Test::Unit::TestCase

  def setup
    @bike1 = MountainBike.new(
      # :type_code => :rigid,
      :tire_width => 2.5,
      :commission => 1000,
      :base_price => 2000,
    )
    @bike2 = MountainBike.new(
      # :type_code => :front_suspension,
      :tire_width => 2.5,
      :front_fork_travel => 3,
      :commission => 1000,
      :base_price => 2000,
      :front_suspension_price => 2000,
    )
    @bike2.type_code = FrontSuspensionMountainBike
    @bike3 = MountainBike.new(
      # :type_code => :full_suspension,
      :tire_width => 2.5,
      :front_fork_travel => 3,
      :rear_fork_travel => 3,
      :commission => 1000,
      :base_price => 2000,
      :front_suspension_price => 2000,
      :rear_suspension_price => 2000,
    )
    @bike3.type_code = FullSuspensionMountainBike
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
