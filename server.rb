require 'em-websocket'
require 'evma_httpserver'
require 'namey'

require './web_page_server'
require './chat_server'

$generator = Namey::Generator.new

class User
  attr_reader :name

  def initialize
    @name = $generator.name(:rare)
  end
end

class NoUser
  def name
    "Nobody"
  end
end

EM.run do
  EM.start_server "0.0.0.0", 9090, WebPageServer

  EM.start_server "127.0.0.1", 9091, ChatServer

  EM::WebSocket.run(:host => "0.0.0.0", :port => 9092, :debug => false) do |ws|
    user = NoUser.new

    ws.onopen do |handshake|
      puts "WebSocket opened #{{
        :path => handshake.path,
        :query => handshake.query,
        :origin => handshake.origin,
      }}"
      user = User.new

      ws.send "Hello #{user.name}!"
    end

    ws.onmessage do |msg|
      puts "Received message: #{msg}"
      ws.send "#{user.name}: #{msg}"
    end

    ws.onclose do
      puts "WebSocket closed"
    end

    ws.onerror do |e|
      puts "Error: #{e.message}"
    end
  end

  puts "Running"
end
