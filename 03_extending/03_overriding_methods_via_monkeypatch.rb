# Ruby provides many ways to override existing methods on objects.
# The first obvious way is to create a new class that inherits from the
# original that redefines the method.
#
#   class AwesomeObject < Object
#     def to_s
#       puts "This is an awesome object"
#     end
#   end
#
# We can also monkeypatch the existing object. This is a quick and easy
# way to completely and radically change core classes in Ruby:
#
#
#  class Object
#    def inspect
#      puts "We modified inspect!"
#    end
#
# When we monkeypatch, we completely replace the original, meaning we can't
# access the original method with <tt>super</tt>.
# 
# In this example, we'll override the behavior of an object's <tt>save</tt>
# method.

## basic class
class Person
  def save
    puts "Original save"
    true
   end
end

## test
require 'test/unit'

class OverridingTest < Test::Unit::TestCase
   def test_overridden_method_returns_false_instead_of_true
     p = Person.new
     assert_equal false, p.save
   end
end

class Person
  def save
    puts "Replaced save"
    false
  end
end



