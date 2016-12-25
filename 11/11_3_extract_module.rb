require 'active_record'

# TODO: before_saveのモジュールがわからん！
# ひとまずactive_record継承で対応してもconnectionするひつようがある。。。
# includeで出来る気がするけどなー
class Bid < ActiveRecord::Base
  # include ActiveModel::Model
  before_save :capture_account_number

  def capture_account_number
    self.account_number = buyer.preferred_account_number
  end
end

require 'test/unit'

class BidTest < Test::Unit::TestCase
  def setup
    @bid = Bid.new
  end
  def test_save
    @bid.save
  end
end
