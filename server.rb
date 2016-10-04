require 'thin'
require 'em-websocket'
require 'sinatra/base'
require 'tilt/erubis'
require "csv"

# server > admin

# * = nove spojeni / list online zarizeni
# - = disconect spojeni

class Database
  attr_reader :online_devices, :authorized, :admin

  def initialize
    @online_devices = {}
    @authorized = read_auth("auth.csv")
    @admin = nil
  end

  def read_auth(file)
    hash = {}
    CSV.open(file,"r") do |csv|
      csv.each{|line| line.each{|d| hash[d] = true}}
    end
    hash
  end

  def write_auth(file)
    temp = []
    CSV.open(file,"w") do |csv|
      @authorized.each_key {|id| temp << id }
    csv << temp
    end

  end

  def admin_login(admin)
    @admin = admin
    puts "Admin is online"
    @admin.send("#{get_time} # Admin has connected")
  end

  def get_time
    Time.now.strftime "%H:%M:%S"
  end


  def send_online(curr=nil)
    return if @admin == nil
    if curr == nil
      list = ""
      @online_devices.each_value do |val|
        list += "," unless list == ""
        list += val
      end
      @admin.send("*#{list}")
    else
      @admin.send("*#{curr}")
      @admin.send("#{get_time} # #{curr} has connected.")
    end

  end

  def delete_offline(ws)
    curr = @online_devices[ws]
    @online_devices.delete ws
    @admin.send("-#{curr}")
    @admin.send("#{get_time} # #{curr} has disconnected.")
  end

  def send_fn(fn)
    @admin.send(fn)
  end

  def disconnect(r)
    @online_devices.key(r).close
  end

  def send_authorized
    tmp = []
    @authorized.each_key {|id| tmp << id}
    @admin.send("Authorized devices: #{tmp.join(",")}")
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

      id_from_origin = handshake.headers["Origin"]
      if sesion.authorized.include? id_from_origin
        ws.send "welcome"
        sesion.online_devices[ws] = id_from_origin
        sesion.send_online(id_from_origin)

      elsif id_from_origin == "http://localhost:3000"

        sesion.admin_login(ws)
        sesion.send_online
      
      else

        puts "unauthorized acces"
        p handshake.headers["Origin"] #TODO write to file
        ws.send "die"
      end
    end

    ws.onclose do
      sesion.delete_offline(ws)
    end

    ws.onmessage do |msg|
      if ws == sesion.admin
        receiver, data = msg.split(",")
        if data == "disconnect"
          sesion.disconnect receiver
        elsif data == "list"
          sesion.send_authorized
        elsif data == "new"
          p msg
          sesion.authorized[receiver] = true
          sesion.write_auth("auth.csv")
          sesion.admin.send("#{receiver} was authorized.")
        else
          sesion.online_devices.each { |ws, id| ws.send data if id == receiver } #TODO creat method
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