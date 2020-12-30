enum Activity
  AssembleFooAndBar
  BuyRobot
  MineFoo
  MineBar
  SellFooBar
end

class Robot
  @last_activity : Nil | Activity
  @id : Int32
  @changing_activity_time : Int32

  def initialize(id : Int32)
    @id = id
    @changing_activity_time = 5
  end

  def choose_activity(channel)
    new_activity = Activity.new(Random.new.rand(Activity.values.size))
    if new_activity != @last_activity
      puts "Changing activity from #{@last_activity} to #{new_activity}"

      # Changing activities takes X seconds
      sleep @changing_activity_time.seconds
      @last_activity = new_activity

      puts "Activity changed to #{new_activity}"
    else
      puts "Activity is the same #{new_activity}"
    end

    channel.send(nil)
  end

end

channel = Channel(Nil).new

start_time = Time.monotonic

robots_size = 2
robots = [] of Robot

# Create the good number of robots
robots_size.times do |i|
  robot = Robot.new i
  robots << robot
end

# Do 6 rounds for now
6.times do
  # Spawn a task per robot
  robots.each do |robot|
    spawn robot.choose_activity(channel)
  end

  robots_size.times do |i|
    channel.receive
  end
end


puts robots

end_time = Time.monotonic
puts "Execution time: #{end_time - start_time}"
