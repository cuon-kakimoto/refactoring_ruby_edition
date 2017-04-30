########################################
# 動的メソッド定義
# [MEMO]
# - モジュールをextendして定義する。
# - 単純にパラメータをどこかに委譲したい場合に、冗長に書いていくべきか？？？
# - No!
# - GOODではないよね。何してるのかわからん。
# - いやー、applicationレベルで組み込みクラスの拡張は怖すぎ。。。
########################################

# [BAD]
# class PostData
#   def initialize(post_data)
#     @post_data = post_data
#   end
# 
#   def params
#     @post_data[:params]
#   end
# 
#   def session
#     @post_data[:session]
#   end
# end

# [GOOD?]
# class PostData
#   def initialize(post_data)
#     (class << self; self; end).class_eval do
#       post_data.each_pair do |key, value|
#         define_method key.to_sym do
#           value
#         end
#       end
#     end
#   end
# end

# [GOOD]
class Hash
  def to_module
    hash = self
    Module.new do
      hash.each_pair do |key, value|
        define_method key.to_sym do
          value
        end
      end
    end
  end
end

class PostData
  def initialize(post_data)
    self.extend post_data.to_module
  end
end

require 'test/unit'

class PostDataTest < Test::Unit::TestCase
  def setup
    @post_data = PostData.new({params: "params", session: "session"})
  end

  def test_state
    assert_equal "params", @post_data.params
    assert_equal "session", @post_data.session
  end
end


