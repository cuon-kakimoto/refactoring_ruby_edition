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
    total_amount, frequent_rental_points = 0, 0
    result = "Rental Record for #{@name}\n"
    @rentals.each do |element|

      # レンタルポイントを加算
      frequent_rental_points += 1
      # 新作２日間レンタルでボーナス点を加算
      if element.movie.price_code == Movie::NEW_RELEASE && element.days_rented > 1
        frequent_rental_points += 1
      end
      #このレンタルの料金を表示
      # OPTIMIZE: リファクタリングをしているときは、パフォーマンスは置いておく.
      result += "\t" + element.movie.title + "\t" + element.charge.to_s + "\n"
      total_amount += element.charge
    end
    # フッター行を追加
    result += "Amount owed is #{total_amount}\n"
    result += "You earned #{frequent_rental_points} frequent renter points"
    result
  end

  # OPTIMIZE: Movieクラスへ移動。Customerクラスの情報を使用していないため。
  # -> メソッドは使っているデータを持つオブジェクトに割り当てるべき
  # 使用していないが、公開インターフェスを変えないために保持
  def amount_for(rental)
    rental.charge
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
  end
end
