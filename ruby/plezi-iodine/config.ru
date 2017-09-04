# # Plezi Rack Application file.
# #
# # Written for Plezi v.0.15 with Iodine v.0.4
# #
# # NOTE: Plezi requires `iodine` for Websocket support.
# #       No Iodine, no websockets.

# # Run using `rackup` or using:
# iodine -t <number of threads> -w <number of processes> -p <port>
# # i.e.:
# iodine -t 8 -p 3334

# local process cluster support is built into iodine's pub/sub, but cross machine pub/sub requires Redis.
require 'iodine'
require 'plezi'
require 'stackprof'

ENV['PL_REDIS_URL'] ||=  "redis://127.0.0.1:6379"

class ShootoutApp

  def index
    "This application should be used with the websocket-shootout benchmark utility."
  end
  
  def on_open
    subscribe channel: "shootout"
  end

  def on_message data

    if data[0] == 'b' # binary
      publish(channel: "shootout", message: data)
      data[0] = 'r'
      write data
      return
    end

    cmd, payload = JSON(data).values_at('type', 'payload')
    if cmd == 'echo'
      write({type: 'echo', payload: payload}.to_json)
    else
      # data = {type: 'broadcast', payload: payload}.to_json
      # broadcast :push2client, data
      publish(channel: "shootout", message: ({type: 'broadcast', payload: payload}.to_json))
      write({type: "broadcastResult", payload: payload}.to_json)
    end

  rescue
    puts "Incoming message format error!"
  end

end

Plezi.route '*', ShootoutApp

use StackProf::Middleware, enabled: true, mode: :wall, interval: 1000, save_every: 5, raw: true
# StackProf.run(mode: :wall, out: 'tmp/stackprof.dump', interval: 10) do
  run Plezi.app
# end


# require 'plezi'

# class ShootoutApp
#   # the default HTTP response
#   def index
#     "This application should be used with the websocket-shootout benchmark utility."
#   end
#   # we won't be using AutoDispatch, but directly using the `on_message` callback.
#   def on_message data
#     cmd, payload = JSON(data).values_at('type', 'payload')
#     if cmd == 'echo'
#       write({type: 'echo', payload: payload}.to_json)
#     else
#       ShootoutApp.broadcast :_send_payload, {type: 'broadcast', payload: payload}.to_json
#       write({type: "broadcastResult", payload: payload}.to_json)
#     end
#   end
#   # send the actual data. This will be invoked by Plezi's broadcast.
#   def _send_payload payload
#     write payload
#   end
# end

# Plezi.route '*', ShootoutApp

# run Plezi.app
