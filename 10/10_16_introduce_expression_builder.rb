require 'uri'
require 'net/http'

class Gateway
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

# OPTIMIZE: オブジェクトが独立のメソッドの集合を提供できるように設計
# method chainの順序を考えなきゃいけないからちょっとめんどくさいな。。。
class GatewayExpressionBuilder
  def initialize(subject)
    @subject = subject
  end

  def post(*attributes)
    @attributes = attributes
    # TODO: @attributesだとArrayクラスを返すことになり、メソッドチェインした場合にmethod missingとなる
    # 対策としてselfを返してみる。
    @gateway = PostGateway
    self
  end

  def get(*attributes)
    @attributes = attributes
    @gateway = GetGateway
    self
  end

  def with_authentication
    @with_authentication = true
    self
  end

  def to(address)
    @gateway.save do |persist|
      persist.subject = @subject
      persist.attributes = @attributes
      persist.authenticate = @with_authentication
      persist.to = address
    end
  end
end

class Person
  attr_accessor :first_name, :last_name, :ssn

  # OPTIMIZE: 独立したメソッドとして理解できるように保つ
  def save
    http.post(:first_name, :last_name, :ssn).to(
      'http://www.example.com/person'
    )
    #PostGateway.save do |persist|
    #  persist.subject = self
    #  persist.attributes = [:first_name, :last_name, :ssn]
    #  persist.to = 'http://www.example.com/person'
    #end
  end
private
  def http
    GatewayExpressionBuilder.new(self)
  end
end

class Company
  attr_accessor :name, :tax_id

  # OPTIMIZE: 独立したメソッドとして理解できるように保つ
  def save
    http.get(:name, :tax_id).to(
      'http://www.example.com/companies'
    )
    # GetGateway.save do |persist|
    #   persist.subject = self
    #   persist.attributes = [:name, :tax_id]
    #   persist.to = 'http://www.example.com/companies'
    # end
  end
private
  def http
    GatewayExpressionBuilder.new(self)
  end
end

class Laptop
  attr_accessor :assigned_to, :serial_number

  # OPTIMIZE: 独立したメソッドとして理解できるように保つ
  def save
    http.post(:assigned_to, :serial_number).with_authentication.to(
      'http://www.example.com/issued_laptop'
    )
    # PostGateway.save do |persist|
    #   persist.subject = self
    #   persist.attributes = [:assigned_to, :serial_number]
    #   persist.authenticate = true
    #   persist.to = 'http://www.example.com/issued_laptop'
    # end
  end
private
  def http
    GatewayExpressionBuilder.new(self)
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
