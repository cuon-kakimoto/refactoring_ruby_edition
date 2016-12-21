module DefaultPrice
  def frequent_renter_points(days_rented)
    1
  end
end

class Movie
  attr_reader :title
  attr_writer :price

  def initialize(title, price)
    @title, @price = title, price
  end

  def charge(days_rented)
    @price.charge(days_rented)
  end

  def frequent_renter_points(days_rented)
    @price.frequent_renter_points(days_rented)
  end
end

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
    result = "Rental Record for #{@name}\n"
    @rentals.each do |rental|
      #このレンタルの料金を表示
      result += "\t" + rental.movie.title + "\t" + rental.charge.to_s + "\n"
    end
    # フッター行を追加
    result += "Amount owed is #{total_charge}\n"
    result += "You earned #{total_frequent_rental_points} frequent renter points"
    result
  end

  def html_statement
    result = "<h1>Rental Record for <em>#{@name}</em></h1><p>\n"
    @rentals.each do |rental|
      #このレンタルの料金を表示
      result += "\t" + rental.movie.title + "\t" + rental.charge.to_s + "<br>\n"
    end
    # フッター行を追加
    result += "<p>You owe <em>#{total_charge}</em><p>\n"
    result += "On this rental you earned " +
      "<em>#{total_frequent_rental_points}</em> " +
      "frequent renter points</p>"
    result
  end

  def amount_for(rental)
    rental.charge
  end

private

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
