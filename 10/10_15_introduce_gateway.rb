########################################
# ゲートウェイの導入
# [MEMO]
# - 「外部システムやリソースを操作するための必要な複雑なAPIを単純な形で提供したい」
# - 外部システムやリソースへのアクセスをカプセル化するゲートウェイを導入する
# - 「Facede」パターンか。
########################################

require 'uri'
require 'net/http'

# OPTIMIZE: GatewayAPIの作成
# 各クラスごとにサーバーへのpost方法が異なり、それぞれのクラスで実装がされていて煩雑。
# サーバへの送信を一元化するGatewayを作成する。
# Templateで共通化できるほど似てもいない。
class Gateway
  # HACK: subjectにはPerson/Compnay...クラスのインスタンスが設定される。
  attr_accessor :subject, :attributes, :to, :authenticate

  def self.save
    gateway = self.new
    yield gateway
    gateway.execute
  end

  def execute
    request = build_request
    request.basic_auth 'username', 'password' if authenticate
    Net::HTTP.new(url.host, url.port).start{|http| http.request(request)}
  end

  def url
    URI.parse(to)
  end
end

class PostGateway < Gateway
  def build_request
    request = Net::HTTP::Post.new(url.path)
    # HACK: subject.send attributeでインスタンスに設定された値が取得できる。
    attribute_hash = attributes.inject({}) do |result, attribute|
      result[attribute.to_s] = subject.send attribute
      result
    end
    request.set_form_data(attribute_hash)
    request
  end
end

class GetGateway < Gateway
  def build_request
    parameters = attributes.collect do |attribute|
      "#{attribute}=#{subject.send(attribute)}"
    end
    Net::HTTP::Get.new("#{url.path}?#{parameters.join("&")}")
  end
end

class Person
  attr_accessor :first_name, :last_name, :ssn

  def save
    # HACK: ブロックを引数に渡すことで、Gatewayクラスのコンテキストで処理が行われる。
    PostGateway.save do |persist|
      persist.subject = self
      persist.attributes = [:first_name, :last_name, :ssn]
      persist.to = 'http://www.example.com/person'
    end

    # OPTIMIZE: Gatewayで一元化
    # url = URI.parse('http://www.example.com/person')
    # request = Net::HTTP::Post.new(url.path)
    # request.set_form_data(
    #   "first_name" => first_name,
    #   "last_name" => last_name,
    #   "ssn" => ssn
    # )
    # Net::HTTP.new(url.host, url.port).start{|http| http.request(request)}
  end
end

class Company
  attr_accessor :name, :tax_id

  def save
    GetGateway.save do |persist|
      persist.subject = self
      persist.attributes = [:name, :tax_id]
      persist.to = 'http://www.example.com/companies'
    end
    # OPTIMIZE: Gatewayで一元化
    # url = URI.parse('http://www.example.com/companies')
    # request = Net::HTTP::Get.new(url.path + "?name=#{name}&tax_id=#{tax_id}")
    # Net::HTTP.new(url.host, url.port).start{|http| http.request(request)}
  end
end

class Laptop
  attr_accessor :assigned_to, :serial_number

  def save
    PostGateway.save do |persist|
      persist.subject = self
      persist.attributes = [:assigned_to, :serial_number]
      persist.authenticate = true
      persist.to = 'http://www.example.com/issued_laptop'
    end

    # OPTIMIZE: Gatewayで一元化
    # url = URI.parse('http://www.example.com/issued_laptop')
    # request = Net::HTTP::Post.new(url.path)
    # request.basic_auth 'username', 'password'
    # request.set_form_data(
    #   "assigned_to" => assigned_to,
    #   "serial_number" => serial_number,
    # )
    # Net::HTTP.new(url.host, url.port).start{|http| http.request(request)}
  end
end

require "test/unit"
require 'webmock'
require 'webmock/test_unit'
include WebMock::API

class PersonTest < Test::Unit::TestCase
  def setup
    stub_request(:post, "http://www.example.com/person").
      with(:body => {"first_name"=>"F", "last_name"=>"L", "ssn"=>"hoge"},
           :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => "", :headers => {})
  end

  def test_person_save
    p = Person.new
    p.first_name = "F"
    p.last_name = "L"
    p.ssn = "hoge"
    assert_equal "200", p.save.code
  end
end

class CompanyTest < Test::Unit::TestCase
  def setup
    stub_request(:get, "http://www.example.com/companies?name=company&tax_id=jp").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => "", :headers => {})
  end

  def test_company_save
    c = Company.new
    c.name = "company"
    c.tax_id = "jp"
    assert_equal "200", c.save.code
  end
end

class LaptopTest < Test::Unit::TestCase
  def setup
    stub_request(:post, "http://www.example.com/issued_laptop").
      with(:body => {"assigned_to"=>"you", "serial_number"=>"1234"},
           :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Basic dXNlcm5hbWU6cGFzc3dvcmQ=', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => "", :headers => {})
  end

  def test_laptop_save
    c = Laptop.new
    c.assigned_to = "you"
    c.serial_number = "1234"
    assert_equal "200", c.save.code
  end
end
