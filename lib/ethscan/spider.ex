defmodule EthScan.Spider do
  use Crawly.Spider

  @impl Crawly.Spider
  def base_url() do
    "https://etherscan.io/tx/"
  end

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "https://etherscan.io/tx/"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(_response) do
    %Crawly.ParsedItem{:items => [], :requests => []}
  end
end
