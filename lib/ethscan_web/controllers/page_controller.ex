defmodule EthscanWeb.PageController do
  use(EthscanWeb, :controller)
  require Logger

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def verify(conn, _params) do
    render(conn, "state.json", %{data: ""})
  end
end
