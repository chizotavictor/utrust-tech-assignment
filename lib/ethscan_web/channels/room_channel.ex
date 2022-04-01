defmodule EthTrx do
  use HTTPoison.Base

  # JSON object return from ethplorer.io
  @expected_fields ~w(
    hash timestamp blockNumber confirmations success from to value
    input gasLimit gasUsed logs error
  )

  # Ethplorer confirmation counts is far behind etherscan
  # It can only resolved if webscrapper is implemented on the etherscan.io
  def process_request_url(url) do
    "https://api.ethplorer.io/getTxInfo" <> url
  end

  def process_response_body(body) do
    body
    |> Poison.decode!()
    |> Map.take(@expected_fields)
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
  end
end

defmodule EthscanWeb.RoomChannel do
  use EthscanWeb, :channel
  require Logger

  @impl true
  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    hash = Enum.map(payload, fn {_, y} -> y end)

    # 1st Attempt with Ethplorer API
    # EthTrx.start()
    # response = EthTrx.get!("/#{hash}?apiKey=freekey")
    # if response.body[:error] do
    #   {:error, %{reason: "empty"}}
    # else
    #   r = %{
    #     confirmations: response.body[:confirmations],
    #     value: response.body[:value],
    #     hash: response.body[:hash]
    #   }
    #   # {:reply, {:ok, r}, socket}
    # end

    # Set a schedule cron job to keep checking for more confirmation counts.
    # Etherscan API implemented.
    get_eth_hash_content(hash, 50, socket)
    # {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:shout).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  def get_eth_hash_content(hash, n, _socket) when n <= 1 do
    Logger.info(hash)
  end

  def get_eth_hash_content(hash, n, socket) do
    # Recursive Loop
    get_eth_hash_content(hash, n - 1, socket)

    :timer.sleep(5000)

    {output, 0} =
      System.cmd("curl", [
        "-XGET",
        "https://etherscan.io/tx/#{hash}"
      ])

    {:ok, document} = Floki.parse_document(output)

    confs =
      document
      |> Floki.find(".u-label.u-label--xs.u-label--badge-in.u-label--secondary.ml-1")
      |> Floki.text()
      |> String.replace(~r/[^\d]/, "")

    eths =
      document
      |> Floki.find(".u-label.u-label--value.u-label--secondary.text-dark.rounded.mr-1")
      |> Floki.text()

    push(
      socket,
      "phx_reply",
      %{
        response: %{
          confirmations: confs,
          eths: eths,
          hash: hash
        },
        status: "ok"
      }
    )
  end

  # Add authorization logic here as required.
  # In case if the user session is persisted
  defp authorized?(_payload) do
    true
  end
end
