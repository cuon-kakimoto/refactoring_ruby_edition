########################################
# 重複する条件分岐の断片の結合
# [MEMO]
# - 条件式の中で同じメソッドコールしてるなら(send_order)、共通部分に出す。
# - 条件によってなにが同じかそうでないかが分かる。
########################################

# - 条件式の中の同じ処理を条件式の外にだす。
# [BAD]
# if special_deal?
#   total = price * 0.95
#   send_order
# else
#   total = price * 0.98
#   send_order
# end
# [BETTER]
# if special_deal?
#   total = price * 0.95
# else
#   total = price * 0.98
# end
# send_order
