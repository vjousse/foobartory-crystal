require "uuid"

enum Activity
  AssembleFooAndBar
  BuyRobot
  MineFoo
  MineBar
  SellFooBar
end

class FooBar
  def initialize(foo : Foo, bar : Bar)
    @foo = foo
    @bar = bar
  end

  def assemble
    "#{@foo}/{@bar}"
  end
end

class Foo
  def initialize(value : String)
    @value = value
  end
end

class Bar
  def initialize(value : String)
    @value = value
  end
end

class Robot
  @last_activity : Nil | Activity
  @id : Int32
  @changing_activity_time : Float64
  @mine_bar_min_time : Float64
  @mine_bar_max_time : Float64

  def initialize(id : Int32, channel : Channel(Nil | Foo | Bar | FooBar), stock_channel : Channel(Array(Foo) | Array(Bar)))
    @id = id
    @changing_activity_time = 0
    @mine_foo_time = 0
    @mine_bar_min_time = 0
    @mine_bar_max_time = 0
    @channel = channel
    @stock_channel = stock_channel
  end

  def choose_activity
    new_activity = Activity.new(Random.new.rand(Activity.values.size))
    foos = [] of Foo
    bars = [] of Bar

    2.times do
      value = @stock_channel.receive
      case value
      when Array(Foo)
        foos = value
      when Array(Bar)
        bars = value
      end
    end

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
    when Activity::AssembleFooAndBar
      latest_foo = foos.pop?
      latest_bar = bars.pop?

      if  latest_foo && latest_bar
        puts "##### #{latest_foo} + #{latest_bar}"
        foobar = self.assemble_foo_and_bar(latest_foo, latest_bar)
        @channel.send(foobar)
      else
        @channel.send(nil)
      end

    else
      @channel.send(nil)
    end
  end

  def mine_bar : Bar
    puts "#{@id} - Mining bar"
    mining_duration = Random.new.rand(@mine_bar_min_time..@mine_bar_max_time)
    sleep mining_duration.seconds
    bar_value = UUID.random.to_s
    puts "#{@id} - Ended mining bar in #{mining_duration} seconds, #{bar_value}"
    Bar.new(bar_value)
  end

  def mine_foo : Foo
    puts "#{@id} - Mining foo"
    sleep @mine_foo_time.seconds
    foo_value = UUID.random.to_s
    puts "#{@id} - Ended mining foo #{foo_value}"
    Foo.new(foo_value)
  end

  def assemble_foo_and_bar(foo : Foo, bar : Bar) : FooBar
    FooBar.new(foo, bar)
  end
end

activity_channel = Channel(Nil | Foo | Bar | FooBar).new
stock_channel = Channel(Array(Foo) | Array(Bar)).new

start_time = Time.monotonic

robots_size = 2
robots = [] of Robot
foos = [] of Foo
bars = [] of Bar
foobars = [] of FooBar

# Create the good number of robots
robots_size.times do |i|
  robot = Robot.new(i, activity_channel, stock_channel)
  robots << robot
end

# Do 6 rounds for now
6.times do
  # Spawn a task per robot
  robots.each do |robot|
    spawn robot.choose_activity
    stock_channel.send(foos)
    stock_channel.send(bars)
  end

  # Wating for the activities results
  robots_size.times do |i|
    value = activity_channel.receive

    puts "# Received #{value}"

    case value
    when Foo
      foos << value
    when Bar
      bars << value
    when FooBar
      foobars << value
    end
  end
end

puts "-> List of Foo (#{foos.size})"
puts foos
puts "-> List of Bar (#{bars.size})"
puts bars
puts "-> List of FooBar (#{foobars.size})"
puts foobars

end_time = Time.monotonic
puts "Execution time: #{end_time - start_time}"
