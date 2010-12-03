#= Creating Callbacks (part 3)
#
# Let's go another step further.
# If we don't get a symbol, then we just take the object
# we get and call the <tt>call</tt> method on the object.
# 
# This means we've created an "interface" and we can
# program to it. We can pass our <tt>before_filter</tt>
# any object that responds to <tt>call</tt>, like a class.
#
# Without changing our existing code, let's add a new
# test that proves we can add a class into the mix.



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
  
  def test_should_take_lambda
    Person.send :before_save,  lambda{|p| p.name = "test"}
    
    p = Person.new
    assert_nil p.name
    p.save
    assert_equal "test", p.name
  end
  
  def test_should_take_a_class
    Person.send :before_save,  SuperFilter
    p = Person.new
    p.save
    assert_not_nil p.name
  end
  
  def test_should_take_method_lambda_and_class
    Person.send :before_save, :foo, lambda{|p| p.name = "test"}, SuperFilter
    p = Person.new
    p.expects(:foo)
    SuperFilter.expects(:call)
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
    self.class.callbacks.each do |c| 
      if c.is_a? Symbol
        self.send c if self.respond_to?(c)
      else
        c.call(self)
      end
    end
    puts "Saved"
  end
end

class Person < Record
   attr_accessor :name
   
end

class SuperFilter
  def self.call(object)
    @object = object
    self.set_name
  end
  
  def self.set_name
    @object.name = "Foo"
  end
end

