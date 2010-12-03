# Now that we've done simple blocks, let's look at a more complex example.
# We can use blocks to write DSLs that look pretty. You've seen those in Rails.
# 
#   create_table :users do |t|
#     t.string :username
#     t.text :bio
#     t.timestamps
#   end
#   
# This is actualy a method called <tt>create_table</tt> that takes a parameter and a block, and it exposes an object to the block so we can interact with it.
# 
# Let's write a simple navbar helper.
# 
#   menu = Navbar.create(:class => "foo") do |m|
#     m.add "Google", "http://www.google.com"
#     m.add "Amazon", "http://www.amazon.com"
#   end
#
## Tests first!
require 'test/unit'
class MenuTest < Test::Unit::TestCase
  
  def test_adds_a_class_to_the_ul
    
    menu = Navbar.create(:class => "foo") do |m|
      m.add "Google", "http://www.google.com"
      m.add "Amazon", "http://www.amazon.com"
    end
    puts menu
    
    assert menu.include?("class='foo'")
    
  end
  
  def test_builds_menu
    
    expected_result = %Q{<ul>
<li><a href='http://www.google.com'>Google</a></li>
<li><a href='http://www.amazon.com'>Amazon</a></li>
</ul>}
    
    menu = Navbar.create do |m|
      m.add "Google", "http://www.google.com"
      m.add "Amazon", "http://www.amazon.com"
    end
    
    assert_equal menu, expected_result
    puts menu
  end


end


## Our outer class
class Navbar
  
  def self.create(options = {}, &block)
    menu = Menu.new
    yield menu
    menu.to_s(options)
  end
 
end

## The menu class
class Menu
  def initialize
    @items = []
  end
  
  def add(name, link)
    @items << {:name => name, :link => link}
  end
  
  def to_s(options)
    css_class = options[:class] ? " class='#{options[:class]}'" : nil
    
    menu = @items.collect do |i|
      "<li><a href='#{i[:link]}'>#{i[:name]}</a></li>"
    end.join("\n")
    
    "<ul#{css_class}>\n#{menu}\n</ul>"
  end
  
end
