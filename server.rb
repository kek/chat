require 'em-websocket'
require 'evma_httpserver'
require 'namey'

require './web_page_server'
require './chat'
require './user'

$generator = Namey::Generator.new

class Server
  WEB_PAGE_PORT = 9090
  WEB_SOCKET_PORT = 9092

  def initialize
    @chat = Chat.new
  end

  def run
    EM.run do
      EM.start_server "0.0.0.0", WEB_PAGE_PORT, WebPageServer

      EM::WebSocket.run(:host => "0.0.0.0",
                        :port => WEB_SOCKET_PORT,
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

      puts "Running on http://localhost:#{WEB_PAGE_PORT}"
    end
  end
end

Server.new.run
