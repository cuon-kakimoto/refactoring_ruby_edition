# [Detail]
# 使われていないデフォルト引数は削除する
# 使われていない柔軟性は悪。
class Something
  # Bad
  # def product_count_items(search_criteria=nil)
  #   criteria = search_criteria | @search_criteria
  #   ProductCountItem.find_all_by_criteria(criteria)
  # end

  # Better
  def product_count_items(search_criteria)
    ProductCountItem.find_all_by_criteria(criteria)
  end
end
