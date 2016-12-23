class Module
  # TODO: メタプログラミングを呼んで理解したい。
  def deprecate(methodName, &block)
    module_eval <<-END
    alias_method :deprecated_#{methodName}, :#{methodName}
    def #{methodName}(*args, &block)
      $stderr.puts "Warning: calling deprecated method #{self}.#{methodName}. This method will be removed in a future release."
      deprecated_#{methodName}(*args, &block)
    end
    END
  end
end

class Foo
  def foo
    puts "in the foo method"
  end
  deprecate :foo
end

Foo.new.foo
