require 'midori'
require 'json'
require 'set'
# require 'redis'
# require 'em-hiredis'

# $redis = Redic.new("redis://localhost:6379")
# $r2 = Redic.new("redis://localhost:6379")
# $redis = EM::Hiredis.connect("redis://localhost:6379/0")

# $redis = Redis.new(url: 'redis://localhost:6379/0')
CONNECTION_POOL = Set.new

class WebsocketAPI < Midori::API

  websocket '/' do |ws|



    ws.on :open do
      # ws.send 'Ohayo Midori'
      CONNECTION_POOL.add ws

      # $redis.pubsub.subscribe('shootout') do |msg|
      #   cmd, payload = JSON(data).values_at('type', 'payload')
      #   ws.send({type: 'broadcastResult', payload: payload}.to_json)
      # end

    end
    
    ws.on :message do |data|

      cmd, payload = JSON(data).values_at('type', 'payload')
      if cmd == 'echo'
        ws.send({type: 'echo', payload: payload}.to_json)
      else
        puts payload
        # $redis.pubsub.publish('shootout', {type: "broadcast", payload: payload}.to_json)
        ws.send({type: 'broadcastResult', payload: payload}.to_json)
        CONNECTION_POOL.each do |client|
          client.send({type: "broadcast", payload: payload}.to_json)
        end
      end
    end
    
    ws.on :close do
      CONNECTION_POOL.delete(ws)
      puts 'Oyasumi midori'
    end
  end
end


Midori::Runner.new(WebsocketAPI).start

