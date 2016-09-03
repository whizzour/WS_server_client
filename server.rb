require 'thin'
require 'em-websocket'
require 'sinatra/base'
require 'tilt/erubis'
# class Device
#   attr_reader :ws, :nick
# def initialize(ws)
#   @ws = ws
#   @nick = nil
# end
#   def get_id(id)
#     @nick = id
#   end
#
# end

class Database
  attr_reader :online_devices, :authorized, :admin
  def initialize
    @online_devices = {}
    @authorized = {"1337" => true, "test_device" => true}
    @admin = nil
  end
  def admin_login(admin)
    @admin = admin
  end
  def send_online
    return if @admin == nil
    list = ""
    @online_devices.each_value do |val|
      list += "," unless list == ""
      list += val
    end
    @admin.send("*#{list}")
  end
  def delete_offline(ws)
    @online_devices.delete ws
    end
def send_fn(fn)
  @admin.send(fn)
end

end


EM.run do
  sesion = Database.new
  class App < Sinatra::Base
    get '/' do
      erb :index
    end
  end

EM::WebSocket.start(:host => '0.0.0.0', :port => '3001') do |ws|

  ws.onopen do |handshake|
    p handshake

    if sesion.authorized.include? handshake.headers["Origin"]
      ws.send "welcome"
      sesion.online_devices[ws] = handshake.headers["Origin"]
      sesion.send_online
    #elseif handshake.headers["origin"] ==
    elsif handshake.headers["Origin"] == "http://localhost:3000"
    puts "Admin is online"
      sesion.admin_login(ws)
      #sesion.admin.send("*#{sesion.online_devices}")
      sesion.send_online
    else
      puts "unauthorized acces"
      p handshake.headers["Origin"]
      ws.send "die"
    end
  end

  ws.onclose do
    sesion.delete_offline(ws)
    sesion.send_online
  end

  ws.onmessage do |msg|
    if msg.strip =~ /fn/
      sesion.online_devices.each do |ws,id|
        ws.send "fn" if id == msg.split(",")[1]
      end
elsif msg.strip[0] == "$"
    sesion.send_fn msg

    end
    puts msg
  end

end
App.run! :port => 3000
end