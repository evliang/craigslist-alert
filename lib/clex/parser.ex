defmodule Clex.Parser do
    def read() do
        File.read!("craigslist")
        |> String.split("\n", trim: true)
        |> Enum.map(&String.split(&1, ",", trim: true))
    end
end