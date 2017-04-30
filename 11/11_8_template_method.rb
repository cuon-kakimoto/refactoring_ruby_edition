########################################
# テンプレートメソッドの作成
# [MEMO]
# - 責務の範囲なら継承を使ってもいいけど、外れるならばNGだろうんな。
# - メソッドオブジェクトを使ってコードを分離する。やっぱりこの、メソッドに対してクラスを分離って思いつかんわ。
# - Strategyパターンで実装 = 状態はもたないで内部処理(アルゴリズム)が変わる。
# - templateパターンってstartegyを切り替えることでメリットがあるんだよな。
# - Statementクラスが直接インスタンス化されないなら継承を使うメリットはない。
# - そして今回は使っていない。
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

  def statement
    TextStatement.value(self)
  end

  def html_statement
    HtmlStatement.value(self)
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

# OPTIMIZE: コードの重複を取り除くため、継承を使ってテンプレートメソッドを用意
class Statement
  #OPTIMIZE: しかし、Statementクラスのインスタンスが作られないなら、モジュールを使うほうが良さそう
  def self.value(customer)
    result = header_string(customer)
    customer.rentals.each do |rental|
      result << each_rental_string(rental)
    end
    result << footer_string(customer)
  end
end

class TextStatement < Statement
  def self.header_string(customer)
    "Rental Record for #{customer.name}\n"
  end

  def self.each_rental_string(rental)
    "\t" + rental.movie.title + "\t" + rental.charge.to_s + "\n"
  end

  #HACK: HereDocument "<<~"でインデントがきれいになる。
  def self.footer_string(customer)
    <<~EOS.chomp
      Amount owed is #{customer.total_charge}
      You earned #{customer.total_frequent_rental_points} frequent renter points
    EOS
  end
end

class HtmlStatement < Statement
  def self.header_string(customer)
    "<h1>Rental Record for <em>#{customer.name}</em></h1><p>\n"
  end

  def self.each_rental_string(rental)
    "\t" + rental.movie.title + "\t" + rental.charge.to_s + "<br>\n"
  end

  def self.footer_string(customer)
    <<~EOS.chomp
      <p>You owe <em>#{customer.total_charge}</em><p>
      On this rental you earned <em>#{customer.total_frequent_rental_points}</em> frequent renter points</p>
    EOS
  end
end


#HACK: 継承方式でtemplateを使った場合、他の表示形式(週末用など)が来た場合に3つのクラスができてエグいことになった。。。
# 状態数 * メール形式の数だけクラスができる! => 状態爆発!!!
#これはやりたくない！！！
class WeekendStatement; end
class TextWeekendStatement1 < WeekendStatement; end
class HtmlWeekendStatement1 < WeekendStatement; end
#もしくは、Statementを継承した上で、[Text|Html]WeekendStatementで選択項目のロジックを実装する。
class TextWeekendStatement2 < Statement; end
class HtmlWeekendStatement2 < Statement; end

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
