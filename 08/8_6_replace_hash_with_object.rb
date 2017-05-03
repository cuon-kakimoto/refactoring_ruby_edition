########################################
# ハッシュからオブジェクトへ
# [MEMO]
# - ハッシュは同種のデータを格納する時に使う。あらゆるデータをハッシュにするのはまずい。
# - => オブジェクトにしてしまおう！
########################################
require 'test/unit'

class Node
  attr_accessor :name
  def initialize(name)
    @name = name
  end
end

class NetworkResult
  attr_reader :old_networks, :nodes
  # attr_accessor :name
  def initialize
    @old_networks, @nodes = [], []
  end

  # OPTIMIZE: 新しく作成したオブジェクトにメソッドが移せる。リファクタリングの真価
  def name
    @old_networks.collect do |network|
      network.name
    end.join(" - ")
  end

  # HACK: hashとArrayでデータの持ち方を変えるんだな。(Arrayは順序がある)
  # どっちも[]の書き換えになるんだ！
  def [](attribute)
    instance_variable_get "@#{attribute}"
  end

  def []=(attribute, value)
    instance_variable_set "@#{attribute}", value
  end

end

class HashTest < Test::Unit::TestCase
  def test_hash
    o1 = Node.new("old_network1")
    o2 = Node.new("old_network2")
    n1 = Node.new("network1")
    new_network = { :nodes => [], :old_networks => [] }
    new_network[:old_networks] << o1
    new_network[:old_networks] << o2
    new_network[:nodes] << "network"

    new_network[:name] = new_network[:old_networks].collect do |network|
      network.name
    end.join(" - ")

    assert_equal "old_network1 - old_network2",new_network[:name]
  end
end

class NetworkResultTest < Test::Unit::TestCase
  def test_network_result
    o1 = Node.new("old_network1")
    o2 = Node.new("old_network2")
    n1 = Node.new("network1")
    new_network = NetworkResult.new
    new_network[:old_networks] << o1
    new_network[:old_networks] << o2
    new_network[:nodes] << n1

    new_network[:name] = new_network[:old_networks].collect do |network|
      network.name
    end.join(" - ")

    assert_equal "old_network1 - old_network2",new_network[:name]
  end

  def test_network_result_accessor
    o1 = Node.new("old_network1")
    o2 = Node.new("old_network2")
    n1 = Node.new("network1")
    new_network = NetworkResult.new
    new_network.old_networks << o1
    new_network.old_networks << o2
    new_network.nodes << n1

    assert_equal "old_network1 - old_network2",new_network.name
  end
end
