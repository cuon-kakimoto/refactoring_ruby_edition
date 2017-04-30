########################################
# テンプレートメソッドの作成(module)
# [MEMO]
# - Statementクラスが直接インスタンス化されてないので、moduleのほうが良いかも
# - 現在の機能Statementクラス、顧客がレンタルしたあらゆる月のビデオ
# - 新規MonthlyStatementクラス、顧客がレンタルしたある月のビデオ
# - どちらが顧客の要望に耐えれるかが設計の指針。
# - やはり継承はシステムのメイン機能でしかつかってはいけないな。
# - 要件の変わりやすい箇所では、柔軟にならずに厄介。
# - ★「抽象クラス」が変化すると、「継承」は変更量が多くなる!!!!!!
# - ↑これだっぁぁぁぁ!
########################################

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
  attr_reader :rentals

  def initialize(name)
    @name = name
    @rentals = []
  end

  def add_rental(arg)
    @rentals << arg
  end

  # OPTIMIZE: モジュールを使って実装
  def statement
    Statement.new.extend(TextStatement).value(self)
  end

  def html_statement
    Statement.new.extend(HtmlStatement).value(self)
  end

  def weekend_statement
    WeekendStatement.new.extend(TextStatement).value(self)
  end

  def weekend_html_statement
    WeekendStatement.new.extend(HtmlStatement).value(self)
  end

  def amount_for(rental)
    rental.charge
  end

  # OPTIMIZE: Steatementに委譲したため、public化
  def total_charge
    rentals.reduce(0) { |sum, rental| sum + rental.charge }
  end

  def total_frequent_rental_points
    rentals.reduce(0) { |sum, rental| sum + rental.frequent_renter_points }
  end
end

class Statement
  def value(customer)
    result = header_string(customer)
    customer.rentals.each do |rental|
      result << each_rental_string(rental)
    end
    result << footer_string(customer)
  end
end

# OPTIMIZE: 新しい出力方式のクラスを作成する場合に、extendであれば日付チェックコードをひとつにまとめることが出来る
class WeekendStatement
  def value(customer)
    result = header_string(customer)
    rentals = customer.rentals.select do |rental|
      rental.days_rented < 3
    end
    rentals.each do |rental|
      result << each_rental_string(rental)
    end
    result << footer_string(customer)
  end
end

# OPTIMIZE: moduleが様々なクラスで使われる場合は、継承ではなく、extendを使う。-> 他のクラスに組み込みが簡単なので拡張子しやすい
# 継承は、ひとつからしか継承できない。
module TextStatement
  def header_string(customer)
    "Rental Record for #{customer.name}\n"
  end

  def each_rental_string(rental)
    "\t" + rental.movie.title + "\t" + rental.charge.to_s + "\n"
  end

  #HACK: HereDocument "<<~"でインデントがきれいになる。
  def footer_string(customer)
    <<~EOS.chomp
      Amount owed is #{customer.total_charge}
      You earned #{customer.total_frequent_rental_points} frequent renter points
    EOS
  end
end

module HtmlStatement
  def header_string(customer)
    "<h1>Rental Record for <em>#{customer.name}</em></h1><p>\n"
  end

  def each_rental_string(rental)
    "\t" + rental.movie.title + "\t" + rental.charge.to_s + "<br>\n"
  end

  def footer_string(customer)
    <<~EOS.chomp
      <p>You owe <em>#{customer.total_charge}</em><p>
      On this rental you earned <em>#{customer.total_frequent_rental_points}</em> frequent renter points</p>
    EOS
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

    assert_equal "Rental Record for Chap\n"           +
                 "Amount owed is 6.5\n"               +
                 "You earned 1 frequent renter points", customer.weekend_statement

    assert_equal "<h1>Rental Record for <em>Chap</em></h1><p>\n"           +
                 "<p>You owe <em>6.5</em><p>\n"                            +
                 "On this rental you earned <em>1</em> frequent renter points</p>", customer.weekend_html_statement
  end
end
