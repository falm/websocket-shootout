require 'faye/websocket'
require 'json'
require 'set'
require 'memory_profiler'
require 'redis'

def redis_connection()
  Redis.new(host: '127.0.0.1', port: '6379') 
end

class Server

  CHANNEL = "shootcut"
  attr_accessor :subscriber

  def initialize
    @conns = Set.new
    # @redis   = redis_connection

    # Thread.new do
    #   redis_sub = redis_connection
    #   redis_sub.subscribe(CHANNEL) do |on|
    #     on.message do |_, msg|
    #       @conns.each {|ws| ws.send(msg) }
    #     end
    #   end
    # end

  end

  def call(env)

    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env)

      ws.on :open do |event|
        @conns.add(ws)
      end

      ws.on :message do |event|
        cmd, payload = JSON(event.data).values_at('type', 'payload')
        #report = MemoryProfiler.report do
          if cmd == 'echo'
            ws.send({type: 'echo', payload: payload}.to_json)
          else
            msg = {type: 'broadcast', payload: payload}.to_json
            @conns.each { |c| c.send(msg) }
            # @redis.publish(CHANNEL, msg)
            ws.send({type: "broadcastResult", payload: payload}.to_json)
          end
        #end
        #report.pretty_print(to_file: './tmp/broadcast_mem.txt')
      end

      ws.on :close do |event|
        @conns.delete(ws)
      end

      ws.rack_response
    else
      [200, {'Content-Type' => 'text/plain'}, ['Please connect a websocket client']]
    end
  end
end
