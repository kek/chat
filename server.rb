require 'em-websocket'
require 'evma_httpserver'
require 'namey'

require './web_page_server'
require './chat_server'

$generator = Namey::Generator.new

class User
  attr_reader :name

  def initialize socket
    @name = $generator.name(:all)
    @socket = socket
  end

  def message msg
    @socket.send msg
  end
end

class NoUser
  def name
    "Nobody"
  end
end

class Chat
  def initialize
    @users = []
  end

  def add_user user
    @users << user
  end

  def broadcast msg
    @users.each do |user|
      user.message msg
    end
  end
end

class Server
  def initialize chat
    @chat = chat
  end

  def run
    EM.run do
      EM.start_server "0.0.0.0", 9090, WebPageServer

      EM::WebSocket.run(:host => "0.0.0.0",
                        :port => 9092,
                        :debug => false) do |ws|
        you = NoUser.new

        ws.onopen do |handshake|
          puts "WebSocket opened #{{
            :path => handshake.path,
            :query => handshake.query,
            :origin => handshake.origin,
          }}"
          you = User.new ws
          @chat.add_user you

          ws.send "Hello #{you.name}!"
        end

        ws.onmessage do |msg|
          @chat.broadcast "#{you.name}: #{msg}"
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
  end
end

Server.new(Chat.new).run
