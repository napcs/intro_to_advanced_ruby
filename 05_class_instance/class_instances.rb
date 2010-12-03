#=Class Instance Variables
#
# In Ruby, classes are objects. We call methods on classes just like we call
# methods on objects. That's why we do
# 
#   p = Person.new
# 
# and now
# 
#   p = new Person
#   
# like we might in Java or other languages. THe <tt>new</tt> method is a class
# method on Person.
# 
# We need to persist data in variables we can share between methods. Instance
# variables are unique to an instance of a class. We use the @ symbol for instance variables, like this:
# 
#   class Person
#     
#     def name=(name)
#       @name = name
#     end
#     
#     def name
#       @name
#     end
#   
#   end
#     
# When we declare two instances of the Person class
# 
#   homer = Person.new
#   bart = Person.new
#   
#   homer.name = "Homer"
#   bart.name = "Bart"
#   
# Each instance's <tt>name</tt> is different. 
# 
# 
# Class variables are unique to the class.
# 
#   class Person
#     
#     @@number_of_people
#     
#     def initialize
#       @@number_of_people += 1
#     end
#     
#   end
# 
# The problem with class variables is that they're also shared by subclasses.
# We want to be able to implement a <tt>before_save</tt> mechanism where we
# specify methods we want to execute before we save a record, similar to the
# way ActiveRecord does. 
# 
# The <tt>before_save</tt> method simply collects the list of methods
# we want to run. We need to store these method names in some kind of collection that we can reference when we save the record, so we can
# call those methods. At first glance, a class variable sounds like 
# a good approach.
# 
#   class Record
#     def self.callbacks
#       @@callbacks
#     end
# 
#     def self.before_save(*args)
#       @@callbacks = args
#     end
# 
#   end
# 
#   class Person < Record
#     before_save :set_active_false
#   end
# 
#   class Note < Record
#     before_save :set_approved_false
#   end
#   
# The problem, though, is that the callback collection is shared by both the Person and Note classes! In the above example, when we save a Person, the
# <tt>set_active_false</tt> method will fire, but so will the <tt>set_approved_false</tt> method we meant to fire for Notes!
# 
# We have to get around that. We do so by introducing the Class Instance scope and Class Instance Variables.
#   
# Methods we define as class methods are in their own scope. If we 
# define instance variables in that scope, those instance variables 
# are usable in that scope only.
# 
#   class Record
#     def self.callbacks
#       @callbacks
#     end
#   
#     def self.before_save(*args)
#       @callbacks = args
#     end
#   end
# 
# The <tt>callbacks</tt> method returns the value of the class instance
# variable so we can retrieve it with 
# 
#   Record.callbacks
#   
# The <tt>before_save</tt> method takes the arguments in and assigns them
# to the @callbacks instance variable. The only thing that denotes that 
# these are class instance variables as opposed to instance variables is
# that we've defined these methods in the class scope, by prefixing the 
# method declarations with <tt>self</tt>.
# 
# An alternative version of this code would be this:
# 
# class Record
#   class << self
#     attr_accessor :callbacks
#     def before_save(*args)
#       self.callbacks = args
#     end
#   end
# end
# 
# The 
# 
#   class << self
#     
# declaration simply encapsulates all of the calls within its scope within the class scope. It's equivalent to prefixing each declaration with <tt>self</self>.
# 
# We can use the <tt>attr_accessor</tt> method to create our getters and
# setters for class instance variables too!



require 'test/unit'

class VariableTest < Test::Unit::TestCase
  
  def test_should_have_two_callbacks_in_the_stack
    Record.send :before_save, :thing1, :thing2
    assert_equal 2, Record.callbacks.count
  end
  
  def test_subclass_should_have_two_callbacks
    Person.send :before_save, :thing1, :thing2
    assert_equal 2, Person.callbacks.count
  end
  
  def test_two_subclasses_should_have_different_callbacks
    Person.send :before_save, :thing1, :thing2
    Note.send :before_save, :bar, :bar2
    
    assert_not_equal Note.callbacks, Person.callbacks
    
  end

end


class Record
  class << self
    attr_accessor :callbacks
    def before_save(*args)
      self.callbacks = args
    end
  end
end

class Person < Record
  
end

class Note < Record
  
end