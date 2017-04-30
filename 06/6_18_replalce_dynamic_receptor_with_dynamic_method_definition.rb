########################################
# 動的レセプタから動的メソッド定義へ:
# method_missingを使わない動的委譲
# [MEMO]
# - method_missing使うのよそう。
# - debugが困難になるよ
# - GODDももはや理解できんけど。
########################################

# [BAD]
# class Decorator
#   def initialize(subject)
#     @subject = subject
#   end
# 
#   def method_missing(sym, *args, &block)
#     @subject.send sym, *args, &block
#   end
# end

# [GOOD]
class Decorator
  def initialize(subject)
    subject.public_methods(false).each do |meth|
      (class << self; self; end).class_eval do 
        define_method meth do |*args|
          subject.send meth, *args
        end
      end
    end
    @subject = subject
  end

  def method_missing(sym, *args, &block)
    @subject.send sym, *args, &block
  end
end

########################################
# 動的レセプタから動的メソッド定義へ:
# ユーザ定義データを使ってメソッドを定義する
# [MEMO]
# - BADのコードを書ける人がすごいわ。
# - method-missingの動的定義つらい。
# - initilaizeで動的定義を全部してしまっていたが、クラスアノテーションでもいいんですね。
# - わかりやすいかなー？
########################################

# [BAD]
# class Person
#   attr_accessor :name, :age
#   def initialize(name, age)
#     @name = name
#     @age = age
#   end
# 
#   def method_missing(sym, *args, &block)
#     empty?(sym.to_s.sub(/^empty_/, "").chomp("?"))
#   end
# 
#   def empty?(sym)
#     self.send(sym).nil?
#   end
# end

# [GOOD]
class Person
  attr_accessor :name, :age
  def initialize(name, age)
    @name = name
    @age = age
  end

  def self.attrs_with_empty_predicate(*args)
    attr_accessor *args
    args.each do |attribute|
      define_method "empty_#{attribute}?" do
        self.send(attribute).nil?
      end
    end
  end

  attrs_with_empty_predicate :name, :age
end
require 'test/unit'

class DecoratorTest < Test::Unit::TestCase
  class Customer
    attr_accessor :name
    def initialize(name)
      @name = name
    end
  end

  def setup
    @customer = Customer.new("shinji")
    @decorator = Decorator.new(@customer)
  end

  def test_state
    assert_equal "shinji", @customer.name
    assert_equal "shinji", @decorator.name
  end
end

class PersonTest < Test::Unit::TestCase
  def setup
    @person = Person.new("shinji", nil)
  end

  def test_state
    assert_equal "shinji", @person.name
    assert_equal true, @person.empty_age?
  end
end


