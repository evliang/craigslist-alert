defmodule Clex.Extractor do
    
    def extract(str) do
        str
        |> Floki.find(".postingtitletext")
        |> Floki.filter_out(".banish-unbanish")
        |> Floki.text
    end
end