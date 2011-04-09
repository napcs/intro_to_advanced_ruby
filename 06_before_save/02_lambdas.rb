#= Creating Callbacks (part 2)
#
# Now let's take our implementation further and
# let's let people pass lambdas in as well!
# We want to be able to support passing lambdas with variables.
#
# To make that work, we'll need to modify how we execute things in our 
# collection. We can use Ruby's <tt>is_a?</tt> method to find out what
# type each entry in our collection is
#
# If it's a symbol, we just call the method using <tt>send</tt> like before.
# if it's not a symbol, we take the entry and call the <tt>call</tt> method
# which invokes the lambda.
# 
#   self.class.callbacks.each do |c| 
#     if c.is_a? Symbol
#       self.send c if self.respond_to?(c)
#     else
#       c.call(self)
#     end
#   end
# 
# Let's test it out:

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

class Person < Record
  attr_accessor :name
  before_save :foo, lambda{|p| p.name = "test"}
 
  def foo
   puts "called foo before save"
  end

end

p = Person.new
p.save
puts p.name

