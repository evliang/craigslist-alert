defmodule Clex.Parser do
    @doc """
    Reads in a JSON-formatted file and turns it into a map
    """
    def read() do
        File.read!(Application.get_env(:clex, :cl_file))
        |> Poison.Parser.parse!
        |> Map.get("items")
    end
end