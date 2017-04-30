########################################
# evalを実行時からパース時へ。
# [MEMO]
# - リファクタリングというよりは性能改善
# - each_pairをよく見るな。eachと同じでした。よりハッシュだと分かるかな。
# - でもevalの使い所がわからん。
# - EmployeeNumberGenerator.nextこんなクラスを作ろうとすることも出来るんですね
# - メソッド定義でevalするとメソッド呼び出しの度にevalされるので、parse時にやればいいよ!
# - sampleでは。define_methodしてるけど駄目なのかな？defだと良い
########################################

class EmployeeNumberGenerator
  def self.next
    1
  end
end

# [BAD]
# class Person
#   def self.attr_with_defalut(options)
#     options.each_pair do |attribute, default_value|
#       define_method attribute do
#         eval "@#{attribute} ||= #{default_value}"
#       end
#     end
#   end
# 
#   attr_with_defalut emails: "[]",
#                     employee_number: "EmployeeNumberGenerator.next"
# end

# [GOOD]
class Person
  def self.attr_with_defalut(options)
    options.each_pair do |attribute, default_value|
      eval "def #{attribute}
              @#{attribute} ||= #{default_value}
            end"
    end
  end

  attr_with_defalut emails: "[]",
                    employee_number: "EmployeeNumberGenerator.next"
end


require 'test/unit'

class PersonTest < Test::Unit::TestCase
  def setup
    @person = Person.new
  end

  def test_state
    assert_equal [], @person.emails
    assert_equal 1, @person.employee_number
  end
end


