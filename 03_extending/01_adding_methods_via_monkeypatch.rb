# We can add methods to our existing core classes by "monkeypatching" or
# opening the existing classes.
#
# Let's add a <tt>blank?</tt> method on Object which returns
# true if the object is either nil or evaluates to an empty string.
#
# Then we'll create an <tt>orelse</tt> method:
#
#   a = "1"
#   b = "2"
#   a.orelse(b)
#
# The method returns the calling object if the calling object is not blank, # and returns the object passed as a parameter if the calling object is
# blank.

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

## Overriding Base Classes

class Object
  def blank?
    self.nil? || self.to_s == ""
  end
  
  def orelse(other)
    self.blank? ? other : self
  end
  
end

