class BenchmarkChannel < ApplicationCable::Channel
  def subscribed
    Rails.logger.info "a client subscribed: #{id}"
    stream_from id
    stream_from "all"
  end

  def echo(data)
    ActionCable.server.broadcast id, data
  end

  def broadcast(data)
    # report = MemoryProfiler.report do
    ActionCable.server.broadcast "all", data
    data["action"] = "broadcastResult"
    ActionCable.server.broadcast id, data
    # end

    # report.pretty_print(to_file: Rails.root.join('tmp', 'broadcast_mem.txt'))
  #

  end
end
