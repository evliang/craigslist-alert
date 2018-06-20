defmodule Clex.Extractor do

    def extract(str) do
        str
        |> Floki.find(".postingtitletext")
        |> Floki.filter_out(".banish-unbanish")
        |> Floki.text
    end

    @doc """
    grabs links from RSS (string)
    """
    def extract_links_from_rss(rss) do
        rss.body
        |> Floki.find("item")
        |> Enum.map(fn x ->
            extract_title_and_price(x)
            |> Map.put(:link, Floki.find(x, "link") |> Floki.text)
        end)
        # rssbody
        # |> Floki.find("items")
        # |> Floki.find("rdf|li")
        # |> Enum.map(fn x ->
        #         Kernel.elem(x, 1)
        #         |> Enum.at(0)
        #         |> Kernel.elem(1) end)
    end

    defp extract_title_and_price(x) do
        title_and_price =
            Floki.find(x, "dc|title")
            |> Enum.map(fn x ->
                Floki.text(x)
                |> String.split(" &#x0024;") end)
            |> Enum.at(0)
        case title_and_price do
            [title, price] -> %{price: price, title: title}
            [title] -> %{title: title}
        end
    end
end