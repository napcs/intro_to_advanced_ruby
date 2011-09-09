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
  def save
    puts "Saved!"
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
    base.extend BeforeSaveCallbacks::ClassMethods
    base.class_eval do
      
      alias_method :original_save, :save
      
      def save
        self.class.callbacks.each do |c| 
          if c.is_a? Symbol
            self.send c if self.respond_to?(c)
          else
            c.call(self)
          end
        end        
      end
    end
  end

end

Record.send :include, BeforeSaveCallbacks

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

##################

class Person < Record
  attr_accessor :name, :active, :updated_at
  before_save :set_active, lambda{|p| p.name = "test"}, LogFilter
  
  def set_active
    self.active = true
  end
end

p = Person.new
p.save

