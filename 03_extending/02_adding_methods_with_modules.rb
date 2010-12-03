# Monkeypatching isn't as elegant as using modules. 
# We can include the module into the class without actually
# redefining the class. We do that by using <tt>send</tt>.
#
#   Object.send :include, MyModule
#
# We'll do the same tests again but refactor our new methods into
# a module...

require 'test/unit'

class OverridingTest < Test::Unit::TestCase
  
  def test_nil_is_blank
    a = nil
    assert a.blank?
  end
  
  def test_empty_string_is_blank
    a = ""
    assert a.blank?
  end
  
  def test_string_with_chars_is_not_blank
    a = "abcd"
    assert !a.blank?
  end
  
  def test_display_the_string_if_not_blank
    a = "Hello"
    b = "Goodbye"
    assert_equal a.orelse(b), a  
  
  end
  
  def test_display_the_passed_object_if_string_is_blank
    a = ""
    b = "Goodbye"
    assert_equal a.orelse(b), b
  end
  
end


module OrElseMethods
  
  def blank?
    self.nil? || self.to_s == ""
  end
  
  def orelse(other)
    self.blank? ? other : self
  end
  
end

Object.send :include, OrElseMethods