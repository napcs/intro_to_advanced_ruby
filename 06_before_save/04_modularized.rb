#= Creating Callbacks (part 4)
#
# Let's turn all of this into a module so we can easily add
# callback support to any object we want.
#
# We know how to override the save method, buy using <tt>included</tt> 
# and <tt>class_eval</tt> in our module. But we need to get our 
# <tt>callbacks</tt> class instance methods on the class, and we 
# also need to use this module to specify <tt>before_save</tt> as a 
# class method, not an instance method. 
#
# When we use <tt>include</tt>, the methods in the module we include
# get added as instance methods to the class that includes
# the module.
#
# Instead, we can use <tt>extend</tt> which adds them as class methods.
# So, we'll separate the class methods in the module by putting them in 
#  a module WITHIN the module:
# 
#   module BeforeSaveCallbacks
#   
#     module ClassMethods
#       attr_accessor :callbacks
#       def before_save(*args)
#          self.callbacks = args
#       end
#     end
#   end
#   
# Then we extend it inside of our <tt>class_eval</tt> block where we
# also overwrite the <tt>save</tt> method.
#
#   def self.included(base)
#     base.class_eval do
#     
#       base.extend BeforeSaveCallbacks::ClassMethods
#     
#       def save
#         self.class.callbacks.each do |c| 
#           if c.is_a? Symbol
#             self.send c if self.respond_to?(c)
#           else
#             c.call(self)
#           end
#         end
#       end
#     end
#   end
# 
# Here are the tests and code to make this work:


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
    SuperFilter.expects(:call)
    p.save
  end
  
  def test_should_take_method_lambda_and_class
    Person.send :before_save, :foo, lambda{|p| p.name = "test"}, SuperFilter
    p = Person.new
    p.expects(:foo)
    SuperFilter.expects(:call)
    p.save
    assert "test", p.name
  end
  
end

class Record
  def save
    puts "Saved!"
  end
end

class SuperFilter
  def self.call(object)
    @object = object
    self.log
  end
  
  def self.log
    puts "Called Superfilter on #{@object.class.to_s}"
  end
end

module BeforeSaveCallbacks
  
  module ClassMethods
    attr_accessor :callbacks
    def before_save(*args)
       self.callbacks = args
    end
  end
  
  def self.included(base)
    base.class_eval do
      
      base.extend BeforeSaveCallbacks::ClassMethods
      
      def save
        self.class.callbacks.each do |c| 
          if c.is_a? Symbol
            self.send c if self.respond_to?(c)
          else
            c.call(self)
          end
        end unless self.class.callbacks.nil?
      end
    end
  end

end

Record.send :include, BeforeSaveCallbacks

##################

class Person < Record
   attr_accessor :name
   before_save :foo, lambda{ puts "called lambda at #{Time.now}" }, SuperFilter
   
   def foo
     puts "called foo before save"
   end
end

p = Person.new
p.save

