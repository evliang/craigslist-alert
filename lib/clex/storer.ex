defmodule Clex.Storer do
    def store(lst, opts) when is_list(lst) do
        lst
        |> Enum.map(&store(&1, opts))
        |> Enum.filter(fn x -> x != nil end)
    end

    @doc """
    Storing item in both Redis sorted set (helps with purging old links)
    and list (for queueing notifications)
    """
    def store(%{link: link} = item, %{"is_new" => true}) do
        case Redix.command!(:redix, ["ZSCORE", "links", link]) do
            nil ->
                Redix.command!(:redix, ["ZADD", "links", DateTime.utc_now |> DateTime.to_unix, link])
                item
            _ -> nil
        end
    end

    def store(%{link: link} = item, _) do
        case Redix.command!(:redix, ["ZSCORE", "links", link]) do
            nil ->
                Redix.command!(:redix, ["ZADD", "links", DateTime.utc_now |> DateTime.to_unix, link])
                Redix.command!(:redix, ["RPUSH", "notifs", item |> :erlang.term_to_binary])
                item
            _ -> nil
        end
    end
end