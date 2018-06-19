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
  
    def handle_info(:trimet, state) do
      schedule_trimet()
      {:noreply, state}
    end

    def handle_info(part1, state) do
      IO.inspect part1, label: "handle_info1"
      IO.inspect state, label: "handle_info2"
      {:noreply, state}
    end
  
    defp schedule_work() do
        schedule_trimet()
    end

    defp schedule_trimet() do
      Process.send_after(self(), :trimet, 30 * 1000)
    end

    defp schedule_stocks() do
      # now = Timex.local
      # next_time =
      #   case {Timex.weekday(now), now.hour } do
      #     {x, y} when x >= 6 or (x == 5 and y > 13) -> now |> Timex.end_of_week |> Timex.shift(hours: 6, minutes: 30)
      #     {_, y} when y < 6 -> now |> Timex.beginning_of_day |> Timex.shift(hours: 6, minutes: 30)
      #     {_, y} when y > 13 -> now |> Timex.end_of_day |> Timex.shift(hours: 6, minutes: 30)
      #     _ -> Timex.shift(now, seconds: 30)
      #   end
      Process.send_after(self(), :stocks, 30 * 1000)
    end
  end