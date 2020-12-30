require "uuid"

enum Activity
  AssembleFooAndBar
  BuyRobot
  MineFoo
  MineBar
  SellFooBar
end

enum Production
  Buy
  Sell
end

alias ActivityChannel = Nil | Foo | Bar | FooBar | Production
alias StockChannel = Array(Foo) | Array(Bar) | Array(FooBar) | Int32

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
  @assemble_foo_bar_time : Float64
  @sell_foo_bar_time : Float64

  def initialize(id : Int32, channel : Channel(ActivityChannel), stock_channel : Channel(StockChannel))
    @id = id
    @changing_activity_time = 0
    @mine_foo_time = 0
    @mine_bar_min_time = 0
    @mine_bar_max_time = 0
    @assemble_foo_bar_time = 0
    @sell_foo_bar_time = 0
    @channel = channel
    @stock_channel = stock_channel
  end

  def id
    @id
  end

  def choose_activity
    new_activity = Activity.new(Random.new.rand(Activity.values.size))
    foos = [] of Foo
    bars = [] of Bar
    foobars = [] of FooBar
    money : Int32 = 0

    4.times do
      value = @stock_channel.receive
      case value
      when Array(Foo)
        foos = value
      when Array(Bar)
        bars = value
      when Array(FooBar)
        foobars = value
      when Int32
        money = value
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

      if latest_foo && latest_bar
        puts "##### #{latest_foo} + #{latest_bar}"
        foobar = self.assemble_foo_and_bar(latest_foo, latest_bar)
        if foobar
          @channel.send(foobar)
        else
          # We keep the bar if it fails
          bars << latest_bar
          @channel.send(nil)
        end
      else
        @channel.send(nil)
      end
    when Activity::SellFooBar
      self.sell_foo_bar(foobars)
      @channel.send(Production::Sell)
    when Activity::BuyRobot
      if self.buy_robot(foos, money)
        @channel.send(Production::Buy)
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

  def assemble_foo_and_bar(foo : Foo, bar : Bar) : Nil | FooBar
    sleep @assemble_foo_bar_time.seconds
    random = Random.new.rand(100)

    if random < 60
      FooBar.new(foo, bar)
    end
  end

  def sell_foo_bar(foobars : Array(FooBar))
    puts "#{@id} - Selling foobar"

    # Sell at most 5 foobars
    foobars.pop(5)
  end

  def buy_robot(foos : Array(Foo), money : Int32) : Bool
    puts "#{@id} - Buying robot, money #{money}€"

    if money >= 3 && foos.size >= 6
      foos.pop(6)
      true
    else
      false
    end
  end
end

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
