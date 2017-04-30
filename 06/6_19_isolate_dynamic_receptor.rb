########################################
# 動的レセプタの定義
# [MEMO]
# - method_missingはクラスのインターフェスを予め決められない時に強力。ARはもろにですか！
# - method_missingを記憶するためだけのクラスを作る。
# - method_missingは境界がわかりにくい。
########################################

# [BAD]
# class Recorder
#   instance_methods.each do |meth|
#     undef_method meth unless meth =~ /^(__|inspect)/
#   end
# 
#   def messages
#     @messages ||= []
#   end
# 
#   def method_missing(sym, *args)
#     messages << [sym, args]
#     self
#   end
# 
#   def play_for(obj)
#     messages.inject(obj) do |result, message|
#       result.send message.first, *message.last
#     end
#   end
# 
#   def to_s
#     messages.inject([]) do |reslut, message|
#       result << "#{message.first}(args: #{message.last.inspect})"
#     end.join(".")
#   end
# end

class CommandCenter
  def start(command_string)
    p "starting...."
    self
  end
  def stop(command_string)
    p "stop...."
    self
  end
end

# [GOOD]
class Recorder
  def record
    @messages_controller ||= MessageController.new
  end

  def play_for(obj)
    @messages_controller.inject(obj) do |result, message|
      result.send message.first, *message.last
    end
  end

  def to_s
    @messages_controller.inject([]) do |reslut, message|
      result << "#{message.first}(args: #{message.last.inspect})"
    end.join(".")
  end
end

class MessageController
  instance_methods.each do |meth|
    undef_method meth unless meth =~ /^(__|inspect)/
  end

  def messages
    @messages ||= []
  end

  def method_missing(sym, *args)
    messages << [sym, args]
    self
  end

end

require 'test/unit'

class RecorderTest < Test::Unit::TestCase
  # def setup
  #   @recorder = Recorder.new
  #   @recorder.start("LRMMMMRL")
  #   @recorder.stop("LRMMMMRL")
  # end

  # def test_recorder
  #   assert_equal [[:start, ["LRMMMMRL"]], [:stop, ["LRMMMMRL"]]], @recorder.messages
  # end
  def setup
    @recorder = Recorder.new
    @recorder.record.start("LRMMMMRL")
    @recorder.record.stop("LRMMMMRL")
  end

  def test_recorder
    assert_equal [[:start, ["LRMMMMRL"]], [:stop, ["LRMMMMRL"]]], @recorder.record.messages
  end
end


