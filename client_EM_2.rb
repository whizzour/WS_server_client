require 'websocket-eventmachine-client'

EM.run do

  ws = WebSocket::EventMachine::Client.connect(:host => '192.168.53.101', :port => 3001, :headers => {:origin => "1337"})

  ws.onopen do

    puts "Connected"
  end

  ws.onmessage do |msg, type|
    puts "Received message: #{msg}"
  end

  ws.onclose do |code, reason|
    puts "Disconnected with status code: #{code}"
  end

  EventMachine.next_tick do
    ws.send "Hello Server!"
  end

end