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
    Person.send :before_save, :bar
    
    
    p = Person.new
    p.expects(:bar)
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
    assert_not_nil p.updated_at
  end
  
  def test_should_take_method_lambda_and_class
    Person.send :before_save, :foo, lambda{|p| p.name = "test"}, SuperFilter
    p = Person.new
    p.expects(:foo)
    p.save
    assert "test", p.name
    assert_not_nil p.updated_at
    
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
      if callback.is_a? Symbol
        self.send callback if self.respond_to? callback
      else
        callback.call(self)
      end
    end
    puts "Saved"
  end
end

class SuperFilter
  def self.call(object)
    object.updated_at = Time.now if object.respond_to? :updated_at
    self.log(object)
  end
  
  def self.log(object)
    puts "Called Superfilter on #{object.class.to_s}"
  end
end

class Person < Record
   attr_accessor :name, :updated_at
   before_save :foo, :bar, lambda{|p| p.name = "test"}, SuperFilter
   
   def foo
     puts "called foo before save"
   end
   
end


p = Person.new
p.save
puts p.name
