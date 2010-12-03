# =Message passing with send and respond_to?
# 
# We know we can call methods on objects. That's basic OO programming.
# 
#     class Person
#        attr_accessor :name
#     end
# 
#     p = Person.new
#     p.name = "Brian"
#     puts p.name
# 
# But sometimes we want to invoke these methods dynamically instead of directly. We can use the send method to do that.
# 
#     p.send :name=, "Brian"
#     puts p.send :name
# 
# However, this can hurt us if we call methods that don't exist, so if we're doing this dynamically, we may want to guard against that case rather than catching an exception. Rails lets us use respond_to? to do that.
# 
#     puts p.respond_to? :name
#     => true
#     puts p.respond_to? :age
#     => false
# 
# That means we can write code like this:
# 
#     p.send(:age) if p.respond_to?(:age)
#     
# Here are some tests and code that demonstrate this

require 'test/unit'

class TestSendRespond < Test::Unit::TestCase
      
  def test_call_method_by_name_with_send
    p = Person.new
    p.name = "Brian"
    assert_equal "Brian", p.send(:name)
  end
  
  def test_call_setter_method_by_name_with_send
    p = Person.new
    p.send :name=, "Brian"
    assert_equal "Brian", p.send(:name)
  end
  
  def test_responds_to_name
    p = Person.new
    assert p.respond_to?(:name)
  end
  
  def test_does_not_respond_to_age
    p = Person.new
    assert !p.respond_to?(:age)
  end
  
end


p.send(:age) if p.respond_to?(:age)




class Person
  attr_accessor(:name)
end


