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
  attr_accessor :name, :active
  before_save :set_active, lambda{|p| p.name = "test"}
 
  def set_active
    self.active = true
  end

end

p = Person.new
p.save
puts p.name

