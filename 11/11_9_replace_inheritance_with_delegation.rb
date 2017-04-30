########################################
# 継承から委譲へ
# [MEMO]
# - サブクラスがスーパークラスがIFの一部しか使っていない。
# - => 完全なサブクラスではなくなっているのでリファクタ。
# - このような状況は、作者の意図が不明になる。
# - 委譲を使うと、部分的にしか使っていないことが明確になる。
########################################

# [misc]
class Rule
  attr_reader :attribute, :defalut_value

  def initialize(attribute, defalut_value)
    @attribute = attribute
    @defalut_value = defalut_value
  end

  def apply(account)
    "apply!"
  end
end

# [BAD] そもそもコレクションから継承しないこと
#class Policy < Hash
#  attr_reader :name
#
#  def initialize(name)
#    @name = name
#  end
#
#  def <<(rule)
#    key = rule.attribute
#    self[key] ||= []
#    self[key] << rule
#  end
#
#  def apply(account)
#    self.each do |attribute, rules|
#      rules.each { |rule| rule.apply(account) }
#    end
#  end
#end

# [GOOD]
require 'forwardable'
class Policy
  extend Forwardable
  def_delegators :@rules, :size, :empty?, :[]
  attr_reader :name

  def initialize(name)
    @name = name
    @rules = {}
  end

  def <<(rule)
    key = rule.attribute.to_sym
    @rules[key] ||= []
    @rules[key] << rule
  end

  def apply(account)
    @rules.each do |attribute, rules|
      rules.each { |rule| rule.apply(account) }
    end
  end
end

require 'test/unit'

class PolicyTest < Test::Unit::TestCase
  def setup
    @policy = Policy.new("policy1")
    @policy << Rule.new(:rule1, "hard")
    @policy << Rule.new(:rule2, "easy")
  end

  # TODO: 良いテストができん!
  def test_apply
    assert_equal [:rule1, :rule2], @policy.apply("shinji").keys
  end

end
