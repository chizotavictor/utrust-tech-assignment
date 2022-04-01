defmodule EthscanWeb.PageView do
  use EthscanWeb, :view

  def render("state.json", %{data: data}) do
    %{data: %{state: data}}
  end
end
