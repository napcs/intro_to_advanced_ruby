#= Creating Callbacks
#
# Let's actually implement the idea of our <tt>before_save</tt> method
# by putting everything we know together.
#
## We want to be able to do this:
#
#  class Person < Record
#    before_save :foo, :bar
#  end
#
#  When we call
#  
#    p = Person.save
#    p.save
# 
# then we want <tt>foo</tt> to fire, then <tt>bar</tt>.
#
# So, the <tt>before_save</tt> method needs to be on the Record class
# as a class method. It should collect the methodnames as symbols, and
# save them to a class instance variable.
#
# The <tt>save</tt> method should be an instance method on Record.
# When called, it should iterate over each entry in the callbacks 
# collection and invoke it if it exists (using <tt>send</tt> and <tt>respond_to?</tt>).

require 'rubygems'
require 'test/unit'
require 'mocha'


class BeforeSaveTest < Test::Unit::TestCase
  
  def test_should_invoke_defined_bar_method_when_specified
    
    Person.send :before_save, :bar, :foo
    
    p = Person.new
    p.expects(:bar)
    p.expects(:foo)
    p.save
    
  end
  
end

class Record
  class << self
    
    attr_accessor :callbacks
    
    def before_save(*args)
       self.callbacks = args
    end
    
    
  end
  
  def save
    self.class.callbacks.each{|c| self.send c if self.respond_to? c}
    puts "Saved"
  end
end

class Person < Record

end