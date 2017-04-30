########################################
# クラスのインライン化
# [MEMO]
# - 「クラスが大した仕事をしていない」: 仕事していないなら作り必要はないっす！
# - attr_accessorの値はinitalizeで初期化すべきだと思ってたけど、そんな必要もないな。
# - 必須項目だけを初期化する。是、かなり間違ってたわ。
# - 後で代入すればいいだけっていううう！！！
# - 前回のGOODがBADになりうる。
########################################

# [BAD]
class Person
  attr_reader :name

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
end

class TelephoneNumber
  attr_accessor :area_code, :number

  def telephone_number
    '(' + area_code + ')' + number
  end

end

# [BAD]
class Person
  attr_reader :name
  attr_accessor :office_area_code
  attr_accessor :office_number

  def initialize(name)
    @name = name
  end

  def telephone_number
    '(' + @office_area_code + ')' + @office_number
  end
end


# [GOOD]
require 'test/unit'

class PersonTest < Test::Unit::TestCase
  def setup
    @person = Person.new("shinji")
    # @person.office_telephone.area_code = "080"
    # @person.office_telephone.number = "08012345678"
    @person.office_area_code = "080"
    @person.office_number = "08012345678"
  end

  def test_state
    assert_equal "(080)08012345678", @person.telephone_number
  end
end

