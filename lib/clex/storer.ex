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
    def store(%{link: link} = item, opt) do
        if is_link_new(link) do
            add_link_to_set(link)
            if opt != nil and is_map(opt) and not Map.get(opt, "is_new", false) do
                item
                |> Map.put(:phone_num, Map.get(opt, "phone_num", Application.get_env(:clex, :twilio_recip)))
                |> queue_notification
            end
        end
    end

    defp is_link_new(link) do
        if Redix.command!(:redix, ["ZSCORE", "links", link]), do: false, else: true
    end
    
    defp add_link_to_set(link) do
        Redix.command!(:redix, ["ZADD", "links", DateTime.utc_now |> DateTime.to_unix, link])
    end

    defp queue_notification(item) do
        Redix.command!(:redix, ["RPUSH", "notifs", item |> :erlang.term_to_binary ])
    end
end