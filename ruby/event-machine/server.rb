require 'em-websocket'
require 'json'
require 'optparse'
require 'stackprof'

address = "0.0.0.0"
port = 3334

OptionParser.new do |opts|
  opts.banner = "Usage: bundle exec server.rb [options]"

  opts.on("-a", "--address", "Address") do |a|
    address = a
  end

  opts.on("-p", "--port PORT", Integer, "Port") do |p|
    port = Integer(p)
  end
end.parse!

EM.epoll if EM.epoll?
EM.kqueue if EM.kqueue?

  #EM.threadpool_size = 8
EM.run {

  @channel = EM::Channel.new

  EM::WebSocket.run(:host => address, :port => port) do |ws|
    # StackProf.run(mode: :wall, raw: true, out: 'tmp/stackprof.dump', interval: 1000, save_every: 5) do
    ws.onopen {
      @channel.subscribe {|msg| ws.send msg }
    }

    ws.onmessage { |msg|
      cmd, payload = JSON(msg).values_at('type', 'payload')
      if cmd == 'echo'
        ws.send({type: 'echo', payload: payload}.to_json)
      else
        @channel.push({type: 'broadcast', payload: payload}.to_json)
        ws.send({type: "broadcastResult", payload: payload}.to_json)
      end
    }
  end
}
