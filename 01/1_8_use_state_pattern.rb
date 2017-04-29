########################################
# direction: case文を削除して、呼び出し元に型インスタンスを生成させる。
# 最後のひとつでごっそり処理が変わってた。
########################################

# OPTIMIZE: モジュール抽出
module DefaultPrice
  def frequent_renter_points(days_rented)
    1
  end
end

class Movie

  attr_reader :title
  attr_writer :price

  # OPTIMIZE: 呼び出し元に型自体のインスタンスを渡させるため、price_codeは不要
  # def initialize(title, the_price_code)
  #   @title, self.price_code = title, the_price_code
  # end
  def initialize(title, price)
    @title, @price = title, price
  end

  # OPTIMIZE: ビデオの種類(price_code)は流動的なため、ビデオの種類は外に公開しない。
  # Movieの中で料金を計算することを選ぶ
  def charge(days_rented)
    @price.charge(days_rented)
  end

  # OPTIMIZE: Priceオブジェクトへ移譲->たしかに料金と映画は紐付かれるとけど、別の値だな。
  def frequent_renter_points(days_rented)
    @price.frequent_renter_points(days_rented)
  end

  # HACK: 下記のメソッドを定義しておけば動的にpriceを変えれる。
  # railsで初期化時に依存性を注入するのってどうやるんだろう？
  # def price=
end

# HACK: stateパターン。
# ちなみに、UMLでは、抽象は<<protocol>>としてる 。動的型付けポリモーフィズム。
class RegularPrice
  include DefaultPrice
  def charge(days_rented)
    result = 2
    result += (days_rented - 2) * 1.5 if days_rented > 2
    result
  end
end

class NewReleasePrice
  def charge(days_rented)
    days_rented * 3
  end

  def frequent_renter_points(days_rented)
    days_rented > 1 ? 2 : 1
  en
  end
end

class ChilderensPrice
  include DefaultPrice
  def charge(days_rented)
    result = 1.5
    result += (days_rented - 3) * 1.5 if days_rented > 3
    result
  end
end

class Rental
  attr_reader :movie, :days_rented

  def initialize(movie, days_rented)
    @movie, @days_rented = movie, days_rented
  end

  # OPTIMIZE: べき等（何度実行しても同じ結果になる)にできているか
  # 副作用がなくなる
  # OPTIMIZE: Movieクラスオブジェクトの値に基づいて条件分岐していたため、Movieへ移動
  def charge
    movie.charge(days_rented)
  end

  def frequent_renter_points
    movie.frequent_renter_points(days_rented)
  end
end

class Customer
  attr_reader :name
  def initialize(name)
    @name = name
    @rentals = []
  end

  def add_rental(arg)
    @rentals << arg
  end

  def statement
    # OPTIMIZE: 一時変数は長くて複雑なルーチンを作るのを助長するため、削除

    result = "Rental Record for #{@name}\n"
    @rentals.each do |element|
      #このレンタルの料金を表示
      # OPTIMIZE: リファクタリングをしているときは、パフォーマンスは置いておく.
      result += "\t" + element.movie.title + "\t" + element.charge.to_s + "\n"
    end
    # フッター行を追加
    # OPTIMIZE: 複数回のループが走るように変更されたためパフォーマンスが気になるが、
    # 「まずはコードをわかりやすくしてからプロファイラを使ってパフォーマンス問題に取り組む」
    result += "Amount owed is #{total_charge}\n"
    result += "You earned #{total_frequent_rental_points} frequent renter points"
    result
  end

  def html_statement
    result = "<h1>Rental Record for <em>#{@name}</em></h1><p>\n"
    @rentals.each do |element|
      #このレンタルの料金を表示
      result += "\t" + element.movie.title + "\t" + element.charge.to_s + "<br>\n"
    end
    # フッター行を追加
    result += "<p>You owe <em>#{total_charge}</em><p>\n"
    result += "On this rental you earned " +
      "<em>#{total_frequent_rental_points}</em> " +
      "frequent renter points</p>"
    result
  end

  # OPTIMIZE: Movieクラスへ移動。Customerクラスの情報を使用していないため。
  # -> メソッドは使っているデータを持つオブジェクトに割り当てるべき
  # 使用していないが、公開インターフェスを変えないために保持
  def amount_for(rental)
    rental.charge
  end

private

  # OPTIMIZE:「ループ」ではなく「コレクションクロージャメソッド」を適用
  def total_charge
    @rentals.reduce(0) { |sum, rental| sum + rental.charge }
  end

  def total_frequent_rental_points
    @rentals.reduce(0) { |sum, rental| sum + rental.frequent_renter_points }
  end
end

require "test/unit"
class VideoRentalTest < Test::Unit::TestCase
  def test_statement
    customer = Customer.new('Chap')
    # OPTIMIZE: 呼び出し元に型自体のインスタンスを割り当てる。流動的要素を注入!
    movie1 = Movie.new("Joe Versus the Volcano", RegularPrice.new)
    rental1 = Rental.new(movie1, 5)
    customer.add_rental(rental1)

    assert_equal "Rental Record for Chap\n"           +
                 "\tJoe Versus the Volcano\t6.5\n"    +
                 "Amount owed is 6.5\n"               +
                 "You earned 1 frequent renter points", customer.statement

    assert_equal "<h1>Rental Record for <em>Chap</em></h1><p>\n"           +
                 "\tJoe Versus the Volcano\t6.5<br>\n"                     +
                 "<p>You owe <em>6.5</em><p>\n"                            +
                 "On this rental you earned <em>1</em> frequent renter points</p>", customer.html_statement
  end
end
