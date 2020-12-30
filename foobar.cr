require "uuid"

enum Activity
  AssembleFooAndBar
  BuyRobot
  MineFoo
  MineBar
  SellFooBar
end

alias Foo = String
alias Bar = String
alias FooBar = Tuple(Foo, Bar)

class Robot
  @last_activity : Nil | Activity
  @id : Int32
  @changing_activity_time : Int32
  @mine_bar_min_time : Float64
  @mine_bar_max_time : Float64

  def initialize(id : Int32, channel : Channel(Nil|Foo|Bar|FooBar))
    @id = id
    @changing_activity_time = 5
    @mine_foo_time = 1
    @mine_bar_min_time = 0.5
    @mine_bar_max_time = 2
    @channel = channel
  end

  def choose_activity()
    new_activity = Activity.new(Random.new.rand(Activity.values.size))
    if new_activity != @last_activity
      puts "#{@id} - Changing activity from #{@last_activity} to #{new_activity}"

      # Changing activities takes X seconds
      sleep @changing_activity_time.seconds
      @last_activity = new_activity

      puts "#{@id} - Activity changed to #{new_activity}"
    else
      puts "#{@id} - Activity is the same #{new_activity}"
    end

    case new_activity
    when Activity::MineFoo
      foo = self.mine_foo
      @channel.send(foo)
    when Activity::MineBar
      bar = self.mine_bar
      @channel.send(bar)
    else
      @channel.send(nil)
    end

  end

  def mine_bar()
    puts "#{@id} - Mining bar"
    mining_duration = Random.new.rand(@mine_bar_min_time..@mine_bar_max_time)
    sleep mining_duration.seconds
    bar_value = UUID.random.to_s
    puts "#{@id} - Ended mining bar in #{mining_duration} seconds, #{bar_value}"
    bar_value
  end

  def mine_foo() : String
    puts "#{@id} - Mining foo"
    sleep @mine_foo_time.seconds
    foo_value = UUID.random.to_s
    puts "#{@id} - Ended mining foo #{foo_value}"
    foo_value
  end

end

channel = Channel(Nil|Foo|Bar|FooBar).new

start_time = Time.monotonic

robots_size = 2
robots = [] of Robot

# Create the good number of robots
robots_size.times do |i|
  robot = Robot.new(i, channel)
  robots << robot
end

# Do 6 rounds for now
6.times do
  # Spawn a task per robot
  robots.each do |robot|
    spawn robot.choose_activity
  end

  robots_size.times do |i|
    value = channel.receive
    puts "# Received #{value}"
  end
end


puts robots

end_time = Time.monotonic
puts "Execution time: #{end_time - start_time}"
