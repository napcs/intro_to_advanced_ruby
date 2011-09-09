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

class BeforeSaveTest < Test::Unit::TestCase
  
  def test_should_invoke_method_before_save_to_set_
    p = Person.new
    p.save
    assert p.active    
  end
  
  def test_should_take_lambda_that_sets_name_to_test    
    p = Person.new
    p.save
    assert_equal "test", p.name
  end
  
  def test_should_use_a_class_to_set_updated_at_field
    p = Person.new
    p.save
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

class LogFilter
  def self.call(object)
    LogFilter.new(object)
  end
  
  def initialize(object)
    @object = object
    log
    set_updated_at
  end
  
  def set_updated_at
    @object.updated_at = Time.now if @object.respond_to? :updated_at
  end
  
  def log
    puts "Called LogFilter on #{@object.class.to_s}"
  end
end

class Person < Record
   attr_accessor :name, :active, :updated_at
   before_save :set_active, lambda{|p| p.name = "test"}, LogFilter
   
   def set_active
     self.active = true
   end
   
end


p = Person.new
p.save
puts p.name
