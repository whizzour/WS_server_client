require 'websocket-eventmachine-client'

id = ARGV[0]
id = "test_device" unless id
fn = "$bluetooth,red_light"

EM.run do

  ws = WebSocket::EventMachine::Client.connect(:host => '192.168.53.101', :port => 3001, :headers => {:Origin => "test_device"})

  ws.onopen do

    puts "Connected"
  end

  ws.onmessage do |msg, type|
    if msg == "fn"
      ws.send fn
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