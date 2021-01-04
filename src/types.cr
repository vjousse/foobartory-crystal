require "habitat"

module Foobartory
  VERSION = "0.1.0"

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
    Habitat.create do
      setting changing_activity_time_sec : Float64
      setting mine_foo_time_sec : Float64
      setting mine_bar_min_time_sec : Float64
      setting mine_bar_max_time_sec : Float64
      setting assemble_foo_bar_time_sec : Float64
      setting sell_foo_bar_time_sec : Float64
    end

    @last_activity : Nil | Activity
    @id : Int32

    def initialize(id : Int32, channel : Channel(ActivityChannel), stock_channel : Channel(StockChannel))
      @id = id
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
        Log.debug { "#{@id} - Changing activity from #{@last_activity} to #{new_activity}" }

        # Changing activities takes X seconds
        sleep settings.changing_activity_time_sec.seconds
        @last_activity = new_activity

        Log.debug { "#{@id} - Activity changed to #{new_activity}" }
      else
        Log.debug { "#{@id} - Activity is the same #{new_activity}" }
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
      Log.debug { "#{@id} - Mining bar" }
      mining_duration = Random.new.rand(settings.mine_bar_min_time_sec..settings.mine_bar_max_time_sec)
      sleep mining_duration.seconds
      bar_value = UUID.random.to_s
      Log.debug { "#{@id} - Ended mining bar in #{mining_duration} seconds, #{bar_value}" }
      Bar.new(bar_value)
    end

    def mine_foo : Foo
      Log.debug { "#{@id} - Mining foo" }
      sleep settings.mine_foo_time_sec.seconds
      foo_value = UUID.random.to_s
      Log.debug { "#{@id} - Ended mining foo #{foo_value}" }
      Foo.new(foo_value)
    end

    def assemble_foo_and_bar(foo : Foo, bar : Bar) : Nil | FooBar
      sleep settings.assemble_foo_bar_time_sec.seconds
      random = Random.new.rand(100)

      if random < 60
        FooBar.new(foo, bar)
      end
    end

    def sell_foo_bar(foobars : Array(FooBar))
      Log.debug { "#{@id} - Selling foobar" }

      # Sell at most 5 foobars
      foobars.pop(5)
    end

    def buy_robot(foos : Array(Foo), money : Int32) : Bool
      Log.debug { "#{@id} - Buying robot, money #{money}€" }

      if money >= 3 && foos.size >= 6
        foos.pop(6)
        true
      else
        false
      end
    end
  end
end
