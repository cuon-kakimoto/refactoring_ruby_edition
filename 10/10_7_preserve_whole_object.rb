########################################
# オブジェクト自体の引き渡し
# [MEMO]
# - ひとつのオブジェクトに含まれる複数のデータをメソッドに渡している時に検討する。
# - [欠点]: オブジェクトを渡すため、依存関係ができる。
# - 呼び出し元が複数の自分のデータを渡してる時はリファクタリングですね。
########################################

# [BAD]
#class Room
#  attr_accessor :days_temperature_range
#
#  def within_plan?(plan)
#    low = days_temperature_range.low
#    high = days_temperature_range.high
#    plan.within_range?(low, high)
#  end
#end
#
#class HeatingPlan
#  def initialize(range)
#    @range = range
#  end
#
#  def within_range?(low,high)
#    (low > @range.low) && (high <= @range.high)
#  end
#end

# [GOOD]
class Room
  attr_accessor :days_temperature_range

  def within_plan?(plan)
    plan.within_range?(days_temperature_range)
  end
end

class HeatingPlan
  def initialize(range)
    @range = range
  end

  def within_range?(room_range)
    (room_range.low > @range.low) && (room_range.high <= @range.high)
  end
end


# [GOOD]
require 'ostruct'
require 'test/unit'
class RoomTest < Test::Unit::TestCase
  def setup
    @room = Room.new
    @room.days_temperature_range = OpenStruct.new(low: 20, high: 30)
    @plan = HeatingPlan.new(OpenStruct.new(low: 10, high: 30))
  end

  def test_within_plan?
    assert_equal true, @room.within_plan?(@plan)
  end
end
