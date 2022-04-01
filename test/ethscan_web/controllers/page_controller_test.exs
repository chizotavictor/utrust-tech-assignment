defmodule EthscanWeb.PageControllerTest do
  use EthscanWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Ethscan · Phoenix Framework"
  end
end
