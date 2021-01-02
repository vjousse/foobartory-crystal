require "./spec_helper"
require "../src/foobartory.cr"

describe Foobartory do

  activity_channel = Channel(Foobartory::ActivityChannel).new
  stock_channel = Channel(Foobartory::StockChannel).new

  robot = Foobartory::Robot.new(1, activity_channel, stock_channel)

  foos = [] of Foobartory::Foo

  it "can't buy robot if not enough foo" do

    robot.buy_robot(foos, 20).should eq(false)

  end

  it "can buy robot if enough foo" do

    7.times do |i|
      foos << Foobartory::Foo.new("myfoo#{i}")
    end

    robot.buy_robot(foos, 20).should eq(true)
  end


  it "can't buy robot if not enough money" do

    7.times do |i|
      foos << Foobartory::Foo.new("myfoo#{i}")
    end

    robot.buy_robot(foos, 2).should eq(false)
  end
end
