defmodule Clex.Parser do
    @doc """
    Reads in a file, formatted as following:
    for-sale-section, keyword1[, keyword2, ...]
    """
    def read() do
        File.read!(Application.get_env(:clex, :cl_file))
        |> Poison.Parser.parse!
        |> Map.get("items")
    end
end