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
#    p = Person.new
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

class BeforeSaveTest < Test::Unit::TestCase
  
  def test_should_invoke_method_before_save_to_set_
    p = Person.new
    p.save
    assert p.active    
  end
  
end


class Record
  def self.callbacks
    @callbacks
  end
  
  def self.before_save(*args)
    @callbacks = args
  end

  def save
    self.class.callbacks.each do |callback|
     self.send callback if self.respond_to? callback
    end
    puts "Saved"
  end  
  
end

class Person < Record
  attr_accessor :name, :active
  before_save :set_active
  
  def set_active
    self.active = true
  end
  
end

p = Person.new
p.save
