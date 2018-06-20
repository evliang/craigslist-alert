defmodule Clex.Storer do
    def store(lst) when is_list(lst) do
        lst
        |> Enum.map(&store(&1))
        |> Enum.filter(fn x -> x != nil end)
    end

    @doc """
    Storing item in both Redis sorted set (helps with purging old links)
    and list (for queueing notifications)
    """
    def store(%{link: link} = item) do
        case Redix.command!(:redix, ["ZSCORE", "links", link]) do
            nil ->
                Redix.command!(:redix, ["ZADD", "links", DateTime.utc_now |> DateTime.to_unix, link])
                Redix.command!(:redix, ["RPUSH", "notifs", item |> :erlang.term_to_binary])
                item
            _ -> nil
        end
    end
end