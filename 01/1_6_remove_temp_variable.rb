class Movie
  REGULAR = 0
  NEW_RELEASE = 1
  CHILDRENS = 2

  attr_reader :title
  attr_accessor :price_code

  def initialize(title, price_code)
    @title, @price_code = title, price_code
  end
end

class Rental
  attr_reader :movie, :days_rented

  def initialize(movie, days_rented)
    @movie, @days_rented = movie, days_rented
  end

  # OPTIMIZE: べき等（何度実行しても同じ結果になる)にできているか
  # 副作用がなくなる
  def charge
    result = 0
    case movie.price_code
    when Movie::REGULAR
      result += 2
      result += (days_rented - 2) * 1.5 if days_rented > 2
    when Movie::NEW_RELEASE
      result += days_rented * 3
    when Movie::CHILDRENS
      result += 1.5
      result += (days_rented - 3 ) * 1.5 if days_rented > 3
    end
    result
  end

  def frequent_renter_points
    (movie.price_code == Movie::NEW_RELEASE && days_rented > 1 ) ? 2 : 1
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
    movie1 = Movie.new("Joe Versus the Volcano", Movie::REGULAR)
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
