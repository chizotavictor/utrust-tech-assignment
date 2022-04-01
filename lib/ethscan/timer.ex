defmodule EthScan.Timer do
  use GenServer
  require Logger

  def init(_) do
    :timer.send_interval(1000, :tick)
    {:ok, 0}
  end

  def handle_info(:tick) do
    IO.puts("Ticking..")
    {:noreply, {}}
  end
end
