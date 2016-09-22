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
    puts "Admin is online"
    @admin.send("#{get_time} # Admin has connected")
  end
  def get_time
    Time.now.strftime"%H:%M:%S"
  end


  def send_online(curr=nil)
    return if @admin == nil
    list = ""
    @online_devices.each_value do |val|
      list += "," unless list == ""
      list += val
    end
    @admin.send("*#{list}")
    @admin.send("#{get_time} # #{curr} has connected.") if curr != nil
  end
  def delete_offline(ws)
    curr = @online_devices[ws]
    @online_devices.delete ws
    @admin.send("#{get_time} # #{curr} has disconnected.")
    end
def send_fn(fn)
  @admin.send(fn)
end

  def disconnect(r)
    @online_devices.key(r).close
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
id_from_origin = handshake.headers["Origin"]
    if sesion.authorized.include? id_from_origin
      ws.send "welcome"
      sesion.online_devices[ws] = id_from_origin
      sesion.send_online(id_from_origin)
      sesion.admin.send ""
    #elseif handshake.headers["origin"] ==
    elsif id_from_origin == "http://localhost:3000"

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
    if ws == sesion.admin
      receiver,data = msg.split(",")
      if data == "disconnect"
      sesion.disconnect receiver
      else
      sesion.online_devices.each {|ws,id| ws.send data if id == receiver}
      end

      elsif sesion.online_devices.has_key?(ws)
    sesion.send_fn msg

    else
    puts msg
      end
  end

end
App.run! :port => 3000
end