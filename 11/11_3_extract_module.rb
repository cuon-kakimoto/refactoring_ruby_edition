########################################
# モジュールの抽出
# [MEMO]
# - 最大の理由は重複を取り除くこと。
# - でも、重複を取り除こうとする時は出来る限りクラスの抽出を使う。
# class A
#   def hoge
#   end
# end
# class B
#   def hoge
#   end
# end
# 
# # ふるまいhogeをクラスに抽出すると、重複が取り除かれて、クラスHogeは独立して再利用、テストできる。
# class Hoge
#   def hoge
#   end
# end
# => 独立して再利用できない。クラスA, Bのコンテキストでしか存在できない場合はmoduleにする。
# また、クラス抽出は別のオブジェクトに委譲することになるので、それが煩雑な場合はmoduleにする。
#
# - ARのコールバックをクラスに抽出しても、再度そのオブジェクトをコールバックさせるだけ。
# - この場合は、moduleだ!
########################################
#
##################################
## AR::Callbacksの動作例(Perfect Ruby on Railsより)
##################################
require 'active_record'
class Music
  extend ActiveModel::Callbacks
  attr_accessor :title, :created_at, :listened_at

  define_model_callbacks :create, :play

  before_play :display_title
  after_create ->(music) { music.created_at = Time.now }

  def self.create(title: nil)
    music = new
    music.title = title
    music.create
  end

  def create
    run_callbacks :create do
      puts "created"
      self
    end
  end

  def play
    run_callbacks :play do
      puts "played"
    end
  end

  private

  def display_title
    puts title
  end
end

music = Music.create(title: "Waltz for Debby")
music.play
##################################
## ここまで
##################################

# [BAD]
# selfに設定しているため、呼び出し元を判断しなければならない。
# =>クラスに抽出しても結局呼び出し元に処理を戻す必要がある。
#class Bid
#  before_save :capture_account_number
#
#  def capture_account_number
#    self.account_number = buyer.preferred_account_number
#  end
#end
#
#class Sale
#  before_save :capture_account_number
#
#  def capture_account_number
#    self.account_number = buyer.preferred_account_number
#  end
#
#end

# [GOOD]
module AccountNumberCapture
  # モジュールをincludeするクラスに固有なもの(self.account_number)を呼び出している場合、
  # メソッドはクラスを対象として呼び出せるようにする
  def self.included(klass)
    klass.class_eval do
      # TODO: やっぱりテストの仕方がわからん、Bidクラスでextend Callbackする必要があるかな。
      # before_save :capture_account_number
    end
  end
  def capture_account_number
    self.account_number = buyer.preferred_account_number
  end
end

class Bid
  include AccountNumberCapture
  # before_save :capture_account_number
end

class Sale
  include AccountNumberCapture
  # before_save :capture_account_number
end

require 'test/unit'
class BidTest < Test::Unit::TestCase
end
