require 'em-websocket'
require 'evma_httpserver'

require './web_page_server'
require './chat_server'

EM.run {
  EM.start_server "0.0.0.0", 9090, WebPageServer

  EM.start_server "127.0.0.1", 9091, ChatServer

  EM::WebSocket.run(:host => "0.0.0.0", :port => 9092, :debug => false) do |ws|
    ws.onopen { |handshake|
      puts "WebSocket opened #{{
        :path => handshake.path,
        :query => handshake.query,
        :origin => handshake.origin,
      }}"

      ws.send "Hello Client!"
    }
    ws.onmessage { |msg|
      ws.send "Pong: #{msg}"
    }
    ws.onclose {
      puts "WebSocket closed"
    }
    ws.onerror { |e|
      puts "Error: #{e.message}"
    }
  end

  puts "Running"
}
