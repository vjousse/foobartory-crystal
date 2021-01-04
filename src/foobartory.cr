require "uuid"

require "./types.cr"

include Foobartory

# Configure the robots settings
Robot.configure do |settings|
  settings.changing_activity_time_sec = 5
  settings.mine_foo_time_sec = 0
  settings.mine_bar_min_time_sec = 0
  settings.mine_bar_max_time_sec = 0
  settings.assemble_foo_bar_time_sec = 0
  settings.sell_foo_bar_time_sec = 0
end


Habitat.raise_if_missing_settings!

activity_channel = Channel(ActivityChannel).new
stock_channel = Channel(StockChannel).new

start_time = Time.monotonic

money = 0

robots = [] of Robot
foos = [] of Foo
bars = [] of Bar
foobars = [] of FooBar

# Create the good number of robots
2.times do |i|
  robot = Robot.new(i, activity_channel, stock_channel)
  robots << robot
end

while robots.size < 60
  puts "## Size #{robots.size} | Money #{money}"

  # Spawn a task per robot
  robots.each do |robot|
    spawn robot.choose_activity
    stock_channel.send(foos)
    stock_channel.send(bars)
    stock_channel.send(foobars)
    stock_channel.send(money)
  end

  # Wating for the activities results
  robots.size.times do |i|
    value = activity_channel.receive

    case value
    when Foo
      foos << value
    when Bar
      bars << value
    when FooBar
      foobars << value
    when Production::Sell
      money += 1
    when Production::Buy
      if robots.size < 60
        money -= 3
        # Add a new Robot
        robot = Robot.new(robots.last.id + 1, activity_channel, stock_channel)
        robots << robot
      else
        break
      end
    end
  end
end

puts "-> List of Foo (#{foos.size})"
puts "-> List of Bar (#{bars.size})"
puts "-> List of FooBar (#{foobars.size})"
puts "-> List of Robots (#{robots.size})"
puts "-> Money #{money}€"

end_time = Time.monotonic
puts "Execution time: #{end_time - start_time}"
