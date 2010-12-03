# Instead of using monkeypatching, we can include our code
# as a module. The problem is that Ruby's modules don't
# work the way you might expect.
# 
#  class Person
#    def save
#      puts "Original save"
#      true
#    end
#  end
# 
# 
# If we override the method using a simple module approach like this:
# 
#   module NoSave
#     def save
#       puts "New save"
#       false
#     end
#   end
# 
#   Person.send :include, NoSave
# 
# and we call
# 
#   p = Person.new
#   p.save
#   
# We'll see only the original save method fires.
# 
# Modules are inserted into the object's inheritence chain. When
# we call a method, Ruby looks first in the object. If the method
# isn't found there, it looks at the parent object, and then it looks
# at the included modules. Since we already have a <tt>save</tt> method
# in our object, Ruby goes no further.
# 
# The workaround involves two Ruby features.
# 
# First, modules can include a method called <tt>self.included</tt> that
# executes whenever the module is included in another object. We 
# can use that method to get access to the object.
# 
#   module NoSave
#     def self.included(base)
#       # base is the reference to the object that included
#       # this module
#     end
#   end
#   
#   
#   
# We can then call any class methods on the object that included the 
# module. This is a great way to separate responsibilities in a Rails application, for example. 
#   
#   module UserValidations
#     def self.included(base)
#       base.validates_presence_of :email, :login
#       base.valudates_uniqueness_of :email, :login
#       base.validates_confirmation_of :password
#     end
#   end
#   
#   class User < ActiveRecord::Base
#     include UserValidations
#   end
#   
# Remember, things like <tt>validates_presence_of</tt> are just class methods
# 
# To override the method in our example, we can use Ruby's <tt>class_eval</tt> method to evaluate a block
# of code and define the methods we want to override.
# This ends up doing nearly exactly what monkeypatching would
# do, but this keeps our code much cleaner and more modular.

#
## basic class
class Person
  def save
    puts "Original save"
    true
  end
end

## test
require 'test/unit'

class OverridingTest < Test::Unit::TestCase
   def test_overridden_method_returns_false_instead_of_true
     p = Person.new
     assert_equal false, p.save
   end
end

## module
module NoSave
  
  def self.included(base)
    base.class_eval do
      def save
        puts "New save"
        false
      end
    end
  end

end

Person.send :include, NoSave


