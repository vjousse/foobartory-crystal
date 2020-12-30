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

  def initialize(id : Int32)
    @id = id
  end

  def choose_activity()
    new_activity = Activity.new(Random.new.rand(Activity.values.size))
    if new_activity != @last_activity
      puts "Changing activity to #{new_activity}"
      @last_activity = new_activity
    end
  end

end

start_time = Time.monotonic

robots_size = 2
robots = [] of Robot

# Create the good number of robots
robots_size.times do |i|
  robot = Robot.new i
  robots << robot
  spawn robot.choose_activity
end

Fiber.yield

puts robots

end_time = Time.monotonic
puts "Execution time: #{end_time - start_time}"
