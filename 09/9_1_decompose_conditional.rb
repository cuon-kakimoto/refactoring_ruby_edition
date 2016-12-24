require 'date'

class Event
  # TODO: 日付処理微妙。どうするのが上手いのだろうか。。。
  SUMMER_START = Date.parse("8/1")
  SUMMER_END   = Date.parse("8/31")

  def initialize
    @winter_rate = 2
    @winter_service_charge = 100
    @summer_rate = 1
  end

  def charge(date, quantity)
    # OPTIMIZE: 目的から名前をつけたメソッド呼び出しを置き、明確なメッセージを伝える
    # HACK: privateメソッドに処理を書いて、publicはコードが分かるようにするのがベストかな-> んー、それに限らす全体が読めるようにかな。
    # HACK: 関数型のほうがテストは楽そう。。。
    if not_summer(date)
      winter_charge(quantity)
    else
      summer_charge(quantity)
    end
  end

private
  def not_summer(date)
    date = Date.parse(date)
    date < SUMMER_START || date > SUMMER_END
  end

  def winter_charge(quantity)
    quantity * @winter_rate + @winter_service_charge
  end

  def summer_charge(quantity)
    quantity * @summer_rate
  end
end

require 'test/unit'

class EventTest < Test::Unit::TestCase
  def test_charge
    e = Event.new
    assert_equal 10, e.charge("8/2", 10)
    assert_equal 120, e.charge("9/1", 10)
  end
end
