defmodule ClexTest.Parser do
    use ExUnit.Case
    doctest Clex
  
    test "parser test" do
        result = Clex.Parser.read()
        result |> is_list |> assert

        result
        |> Enum.each(fn item ->
            item |> is_map |> assert
            item |> Map.has_key?("category") |> assert
            item |> Map.has_key?("city") |> assert
            item |> Map.has_key?("keywords") |> assert
            item["keywords"] |> is_list |> assert
            item["keywords"] |> Enum.any?() |> assert
        end)
    end
end
  