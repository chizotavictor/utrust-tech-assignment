defmodule EthscanWeb.RoomChannelTest do
  use EthscanWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      EthscanWeb.EtherScanSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(EthscanWeb.RoomChannel, "room:lobby")

    %{socket: socket}
  end

  # Test for the hash -> ping [Payment Confirmation]
  test "ping replies with status ok", %{socket: socket} do
    ref = push(socket, "ping", %{"hello" => "there"})
    assert_reply ref, :ok, %{"hello" => "there"}
    # end_reply(ref, :ok, %{eths: 0.00, confirmations: 0, hash: ''})
  end

  # test "shout broadcasts to room:lobby", %{socket: socket} do
  #   push(socket, "shout", %{"hello" => "all"})
  #   assert_broadcast "shout", %{"hello" => "all"}
  # end

  # test "broadcasts are pushed to the client", %{socket: socket} do
  #   broadcast_from!(socket, "broadcast", %{"some" => "data"})
  #   assert_push "broadcast", %{"some" => "data"}
  # end
end
