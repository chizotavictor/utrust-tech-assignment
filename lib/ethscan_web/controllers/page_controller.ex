defmodule EthscanWeb.PageController do
  use EthscanWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
