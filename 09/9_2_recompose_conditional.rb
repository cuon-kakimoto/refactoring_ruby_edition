########################################
# 条件分岐の組み換え
# [MEMO]
# - ifの条件をreturnするほうがわかりよいのかな？？？
# - => 「英語に近いコードになる」。英語圏特有かも
########################################
#
# - 三項演算子から"OR"代入へ
# [BAD]
# parameters = params ? params : []
# [BETTER]
# parameters = params || []

# - 条件分岐から明示的なreturnへ
# [BAD]
# def reward_points
#   if days_rented > 2
#     2
#   else
#     1
#   end
# end
# [BETTER]
# def reward_points
#   return 2 if days_rented > 2
#   1
# end
