########################################
# 動的メソッド定義
# [MEMO]
# - 読みやすいメンテナンスしやすい形式でメソッド定義を表現できる。
# - だから、メンテナンス性から外れるなら便利という理由で使うべきではニノよね。
# - クラスアノテーションは確かにわかりやすいなー。
# - [:failure, :error, :success].each ...より
# - states :failure, :error, :successこういうコードを書くべきですね。
########################################

class Class
  attr_accessor :state

  # OPTIMIZE: PROGRESS1: 冗長な類似メソッド定義を削除
  # def failure
  #   self.state = :failure
  # end
  # def error
  #   self.state = :error
  # end
  # def success
  #   self.state = :success
  # end

  # OPTIMIZE: PROGRESS2: ループ内でメソッド定義。可読性の低いコードを改善
  # HACK: 仕事でこういうコード書いてた...
  # [:failure, :error, :success].each do |method|
  #   define_method method do
  #     self.state = method
  #   end
  # end

  # OPTIMIZE: PROGRESS3: メソッド内で動的定義に気付く易くなり、していることも理解しやすい
  # HACK: *method_names: [:failure, :error, :success]
  #       &block: do |method_name| self.state = method_name end
  #       もうブロックは理解できるよね？
  # HACK: この処理ではyieldが使われてないのでなにもされてない。
  def def_each(*method_names, &block)
    method_names.each do |method_name|
      define_method method_name do
        instance_exec method_name, &block
      end
    end
  end

  # # HACK: 動的定義とメソッド処理を分割して考えているのが上手いな
  # # 動的定義も一つの処理だから、責務を分割するとこんなにも分かりやすい
  # #
  # def_each :failure, :error, :success do |method_name|
  #   self.state = method_name
  # end

  # OPTIMIZE: PROGRESS4: クラスアノテーションによるインスタンスメソッドの定義
  # HACK: これ驚異的なわかりやすさだな。。。
  # でも使い方が全くわからんくない？
  def self.states(*args)
    # HACK: 追加でdef_eachメソッドを使用してみる
    def_each *args do |method_name|
      self.state = method_name
    end
    # args.each do |arg|
    #   define_method arg do
    #     self.state = arg
    #   end
    # end
  end

  states :failure, :error, :success

end

require 'test/unit'

class ClassTest < Test::Unit::TestCase
  def setup
    @class = Class.new
  end

  def test_state
    @class.failure
    assert_equal :failure, @class.state
    @class.error
    assert_equal :error, @class.state
    @class.success
    assert_equal :success, @class.state
  end
end


