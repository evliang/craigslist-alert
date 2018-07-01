defmodule Clex.Periodically do
    use GenServer
  
    def start_link do
      GenServer.start_link(__MODULE__, %{})
    end
  
    def init(state) do
      IO.puts "init periodically"
      schedule_work() # Schedule work to be performed at some point
      {:ok, state}
    end
  
    def handle_info(:fetchrss, state) do
        #todo: Parser.read -> add items to queue
        Clex.Parser.parse_file()
        |> Clex.Parser.mark_new()
        |> Enum.each(fn x ->
            Clex.Downloader.download_rss(x)
            |> Clex.Extractor.extract_links_from_rss
            #filters results on price, if applicable (todo: exclude words)
            |> filter_items(x)
            |> Clex.Storer.store(x)
            :timer.sleep(1000) #todo: code smell
        end)
        schedule_rss()
        {:noreply, state}
    end

    def handle_info(:notify, state) do
        Clex.Notifier.notify()
        schedule_notifier()
        {:noreply, state}
    end

    def handle_info(part1, state) do
      IO.inspect part1, label: "handle_info1"
      IO.inspect state, label: "handle_info2"
      {:noreply, state}
    end
  
    defp schedule_work() do
        schedule_rss()
        schedule_notifier()
    end

    defp schedule_rss() do
        { min_time, interval } = define_rss_times()
        Process.send_after(self(), :fetchrss, (min_time + :rand.uniform(interval)) * 60000)
    end

    defp schedule_notifier() do
        Process.send_after(self(), :notify, 3 * 1000)
    end

    def filter_items(to_send, %{"max_price" => max_price} = filters) do
        to_send
        |> Enum.filter(fn x ->
            (Map.has_key?(x, :price) && x[:price] <= max_price)
            or !Map.has_key?(x, :price) end)
        |> filter_items(filters |> Map.delete("max_price"))
    end

    def filter_items(to_send, %{"min_price" => min_price} = filters) do
        to_send
        |> Enum.filter(fn x ->
            (Map.has_key?(x, :price) && x[:price] >= min_price)
            or !Map.has_key?(x, :price) end)
        |> filter_items(filters |> Map.delete("min_price"))
    end

    def filter_items(to_send, _), do: to_send

    #the idea is to check less frequently when I'm sleeping with a little bit of paranoia that CL will ban me
    defp define_rss_times() do
        case :calendar.local_time do
            {_, {x, _, _}} when x < 5 or x > 21 ->
                {120, 30}
            _ ->
                {5, 10}
        end
    end
end