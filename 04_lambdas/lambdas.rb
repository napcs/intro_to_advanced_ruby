#=Lambdas
#
# Lambdas let us define code by wrapping it in a Proc object which we can call later. It's delayed execution of code and comes in really handy for DSLs. To demonstrate, we can use times.
# 
#     a = Time.now
#     puts a
#     sleep 1
#     puts a
# 
# If we run that, the time is frozen. If we wrap the Time in a lambda and change our code like this:
# 
#     a = lambda{ Time.now }
#     puts a.call
#     sleep 1
#     puts a.call
#     
# The times are now different. When we execute the call() method, the code within the lambda is executed.
# 
# We can pass values to lambdas too.
# 
#     a = lambda{|phrase| puts "#{phrase} at #{Time.now}" }
#     puts a.call("Hello")
#     sleep 1
#     puts a.call("Goodbye")
#    
# We use lambdas a lot in Rails scopes for ActiveRecord because scopes are declared at the class level and not the instance level. Using a lambda lets us run the code to construct the query at runtime.
#    
#    scope :upcoming_events, lambda{
#      where("starts_at >= ?", Time.now)  
#    }
#   
# Without the lambda, the value for the time would be saved on the first run and used subsequently.



## Lambdas and delayed execution
a = Time.now
b = lambda{ Time.now }
puts "=== NO LAMBDA ===="
puts a
sleep 1
puts a
sleep 1
puts a

puts "=== LAMBDA ===="


sleep 1
puts b.call
sleep 1
puts b.call
sleep 1
puts b.call


a = lambda{|phrase| puts "#{phrase} at #{Time.now}" }
puts a.call("Hello")
sleep 1
puts a.call("Goodbye")