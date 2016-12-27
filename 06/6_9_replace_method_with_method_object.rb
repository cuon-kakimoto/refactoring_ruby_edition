# OPTIMIZE: メソッドをオブジェクトに抽出することで、そのオブジェクト内でリファクタリング可能に
class Account

  attr_reader :delta

  def initialize(delta)
    @delta = delta
  end

  def gamma(input_val, quantity, year_to_date)
    Gamma.new(self, input_val, quantity, year_to_date).compute
    # important_value1 = ( input_val * quantity) + delta
    # important_value2 = ( input_val * year_to_date) + 100
    # if ( year_to_date - important_value1) > 100
    #   important_value2 -= 20
    # end
    # important_value3 = important_value2 * 7
  end
end

# OPTIMIZE: 元のオブジェクトとメソッドの内の引数、一時変数のための属性を宣言
# OPTIMIZE: 新しいクラスは元のメソッド名を元に命名
# OPTIMIZE: 全てのローカル変数が属性になっているので、引数を考慮する必要がない。
class Gamma
  attr_reader :account
  attr_reader :input_val
  attr_reader :quantity
  attr_reader :year_to_date
  attr_reader :important_value1
  attr_reader :important_value2
  attr_reader :important_value3

  def initialize(account, input_val_arg, quantity_arg, year_to_date_arg)
    @account      = account
    @input_val    = input_val_arg
    @quantity     = quantity_arg
    @year_to_date = year_to_date_arg
  end

  # HACK: 直接アクセスと間接アクセスで変数スコープが変わりそう。「@」必須
  def compute
    @important_value1 = ( input_val * quantity) + account.delta
    @important_value2 = ( input_val * year_to_date) + 100
    important_thing
    # if ( year_to_date - important_value1) > 100
    #   important_value2 -= 20
    # end
    @important_value3 = @important_value2 * 7
  end

  # HACK: 元のAccountクラスから分離されたため、メソッド抽出のリファクタリングが容易
  def important_thing
    if ( year_to_date - @important_value1) > 100
      @important_value2 -= 20
    end
  end

end


require 'test/unit'

class AccountTest < Test::Unit::TestCase
  def setup
    @account = Account.new(10)
  end

  def test_gamma
    assert_equal 770700, @account.gamma(100, 10, 1100)
    assert_equal 840560, @account.gamma(100, 10, 1200)
  end
end
