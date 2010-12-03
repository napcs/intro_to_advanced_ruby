# We've all seen blocks.
# 
#   @users.each do |user|
#     puts "Hello #{user.name}"
#   end
# 
# Blocks let us execute code in the context of other code. They're easy to write, too. Let's write a simple method that wraps text in any HTML element we specify. We'll make it look like this:
# 
#   wrap(:p) do
#    "Hello world"
#   end
#   
# And it should generate
# 
#   <p>Hello world</p>

require 'test/unit'
class WrapTest < Test::Unit::TestCase

  def test_wraps_string_with_p_tags
    result = wrap(:p) do
               "Hello world"
             end
             
    assert_equal "<p>Hello world</p>", result
    puts result
  end

end

def wrap(tag, &block)
  output = "<#{tag}>#{yield}</#{tag}>"
end
