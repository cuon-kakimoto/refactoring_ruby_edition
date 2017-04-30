########################################
# コレクションのカプセル化
# [MEMO]
# - コレクションのコピーを返して、add_, removeメソッドを用意する
# - コレクションオブジェクトを返すことがないので、内部がカプセル化される。
########################################
#
class Course
  # HACK: アクセサメソッドを定義すると外部から参照できるんだな。。。
  # なので、writerを禁じる.
  def initialize(name, advanced)
    @name = name
    @advanced = advanced
  end

  # HACK: *?は条件分岐ひつようなし。
  def advanced?
    @advanced
    # if advanced
    #   true
    # else
    #   false
    # end
  end
end

# OPTIMIZE: personのメソッドを使う以外の方法でコレクションの要素に変更が加わらないように、カプセル化を行う。
# コレクションオブジェクトを返すと、オーナ側が勝手に書き換える可能性がある。
class Person
  attr_accessor :courses

  def initialize
    @courses = []
  end
  # HACK: 間接アクセサが定義されているけれど、直接アクセスしたほうが分かりやすいな。
  def add_course(course)
    @courses << course
  end

  def remove_course(course)
    @courses.delete(course)
  end

  # HACK: addを繰り返すので、メソッド名と処理が一致していない。「メソッド名の変更」を適用する必要がある。
  def courses=(courses)
    raise "Courses should be empty" unless @courses.empty?
    courses.each { |course| add_course(course) }
  end

  # OPTIMIZE: 属性リーダによる書き換えを不能にする
  def courses
    @courses.dup
  end

  # OPTIMIZE: 属性リーダが使われている箇所をクラスに移動する
  def number_of_advances_courses
    @courses.select{ |course| course.advanced? }.size
  end

  # HACK: 小さいけど絶大な感じがするリファクタリングだな。
  def number_of_courses
    @courses.size
  end
end

require 'test/unit'

class CourseTest < Test::Unit::TestCase
  def test_course
    kent = Person.new
    courses = []
    courses << Course.new("SmallTalk Programming", false)
    courses << Course.new("Appreciating Single Malts", true)

    kent.courses = courses
    assert_equal 2, kent.courses.size
    refactoring = Course.new("Refactoring", true)
    # OPTIMIZE: 属性リーダによる書き換えが不能により、テストが失敗するようになる。
    # kent.courses << refactoring
    # kent.courses << Course.new("Brutal Sarcasm", false)
    # assert_equal 4, kent.courses.size
    # kent.courses.delete(refactoring)
    # assert_equal 3, kent.courses.size

    # assert_equal 1, kent.courses.select{ |course| course.advanced }.size
  end

  def test_course_optimize
    kent = Person.new
    kent.add_course (Course.new("SmallTalk Programming", false))
    kent.add_course (Course.new("Appreciating Single Malts", true))

    assert_equal 2, kent.number_of_courses
    refactoring = Course.new("Refactoring", true)
    kent.add_course refactoring
    kent.add_course Course.new("Brutal Sarcasm", false)
    assert_equal 4, kent.number_of_courses
    kent.remove_course(refactoring)
    assert_equal 3, kent.number_of_courses

    assert_equal 1, kent.number_of_advances_courses
  end
end
