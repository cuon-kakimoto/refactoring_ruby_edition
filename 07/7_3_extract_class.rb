########################################
# クラスの抽出
# [MEMO]
# - これがまさにvalueオブジェクトだな。やりすぎると終わらなくなる。
# - でも、前回のメソッドレベルでクラスをつくるって結構思い切ってるよな。
# - クライアントにたいしてどの程度新クラスを公開するかを決める。大事な作業！！！！
# - 選択肢
# - 1. 任意のオブジェクトが電話番号の任意の部分を書き換えることを受け入れる。
# - 2. Presonを経由せずに電話番号を書き換えれれないようにする
# - 3. TelephoneNumberにfreezeを掛ける。
# - 選択肢があまりピンとこなかった...
# - 現実世界では、人が電話番号を変えるのは自然だな。。。
# - でも、いまのGOODはメソッド数が多くなりすぎてませんか？
########################################

# [BAD]
# class Person
#   attr_reader :name
#   attr_accessor :office_area_code
#   attr_accessor :office_number
# 
#   def initialize(name, office_area_code, office_number)
#     @name = name
#     @office_area_code = office_area_code
#     @office_number = office_number
#   end
# 
#   def telephone_number
#     '(' + @office_area_code + ')' + @office_number
#   end
# end

# [GOOD]
class Person
  attr_reader :name

  # HACK: PersonからTelephoneNumberへのリンクを作ると表現されていた。そういうのか。
  def initialize(name)
    @name = name
    @office_telephone = TelephoneNumber.new
  end

  def telephone_number
    @office_telephone.telephone_number
  end

  def office_telephone
    @office_telephone
  end

  def office_area_code
    @office_telephone.area_code
  end

  def office_area_code=(arg)
    @office_telephone.area_code = arg
  end

  def office_number
    @office_telephone.number
  end

  def office_number=(arg)
    @office_telephone.number = arg
  end
end

class TelephoneNumber
  attr_accessor :area_code, :number

  def telephone_number
    '(' + area_code + ')' + number
  end

end


# [GOOD]
require 'test/unit'

class PersonTest < Test::Unit::TestCase
  def setup
    @person = Person.new("shinji")
    @person.office_area_code = "080"
    @person.office_number = "08012345678"
  end

  def test_state
    assert_equal "(080)08012345678", @person.telephone_number
  end
end

