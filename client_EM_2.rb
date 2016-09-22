require 'websocket-eventmachine-client'

fn = "$EMP,blue_light"
EM.run do

  ws = WebSocket::EventMachine::Client.connect(:host => '192.168.80.1', :port => 3001, :headers => {:Origin => "1337"})

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