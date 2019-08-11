defmodule Clex.Parser do
    @doc """
    Reads in a JSON-formatted file and turns it into a list of maps
    """
    def parse_file() do
        File.read!(Application.get_env(:clex, :cl_file))
        |> Poison.Parser.parse!
        |> Map.get("items")
        |> Enum.map(fn x -> Map.put_new(x, "category", "sss") end)
        |> mark_new
    end

    @doc """
    Marks new items in configuration (to avoid getting mass-spammed with notifications when adding new items to configuration file)
    """
    def mark_new(lst) do
        new_set = MapSet.new(lst)
        old_set = (Redix.command!(:redix, ["GET", "config_map"]) || <<131, 106>>)
                    |> :erlang.binary_to_term
                    |> MapSet.new
        diff = MapSet.difference(new_set, old_set)

        Redix.command!(:redix, ["SET", "config_map", lst |> :erlang.term_to_binary ])

        lst
        |> Enum.map(fn x ->
            case MapSet.member?(diff, x) do
                true -> Map.put(x, "is_new", true)
                false -> x
            end
        end)
    end
end