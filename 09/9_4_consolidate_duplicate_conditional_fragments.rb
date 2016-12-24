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
