require 'websocket-eventmachine-client'

id = ARGV[0]
id = "test_device" unless id
fn = "$bluetooth,red_light"

class Device
  def initialize
    @bluetooth = false
    @red_light = false
  end
def toggle
  @red_light = @red_light ? false : true
end
end

EM.run do
device = Device.new
  ws = WebSocket::EventMachine::Client.connect(:host => '192.168.80.1', :port => 3001, :headers => {:Origin => "test_device"})

  ws.onopen do

    puts "Connected"
  end

  ws.onmessage do |msg, type|
    if msg == "fn"
      ws.send fn
    elsif msg == "red_light"
      device.toggle
    p device
    end

    puts "Received message: #{msg}"
  end

  ws.onclose do |code, reason|
    puts "Disconnected with status code: #{code}"
  end

  EventMachine.next_tick do
    ws.send "Hello Server!"
  end

end