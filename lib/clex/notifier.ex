defmodule Clex.Notifier do
    def notify() do
        Redix.command!(:redix, ["LPOP", "notifs"])
        |> handle_redis_response
    end

    defp handle_redis_response(nil), do: nil

    defp handle_redis_response(binary) do
        binary
        |> :erlang.binary_to_term
        |> create_message
        |> send_message
        |> handle_blitz_response
    end

    defp create_message(%{price: price, title: title, link: link}) do
        "#{price} - #{title}%0a#{link}"
    end

    defp create_message(%{title: title, link: link}) do
        "#{title}%0a#{link}"        
    end

    defp send_message(msg) do
        SmsBlitz.send_sms(
            :twilio,
            from: System.get_env("TWILIO_SENDER"),
            to: System.get_env("TWILIO_RECIP"),
            message: msg)
    end

    defp handle_blitz_response(lst) when is_list(lst) do
        lst
        |> Enum.each(&handle_blitz_response(&1))
    end

    defp handle_blitz_response(%{id: _i, result_string: _r, status_code: _sc} = map) do
        IO.inspect map
    end
end