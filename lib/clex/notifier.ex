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
        "$#{price} - #{title_and_link_msg(title, link, String.length(price) + 4)}"
    end

    defp create_message(%{title: title, link: link}) do
        title_and_link_msg(title, link)
    end

    defp title_and_link_msg(title, link, offset \\ 0) do
        #160-twilio sms limit. 37-text related to trial. 2-newline
        title_length = 160 - 37 - offset - 2 - String.length(link)
        "#{String.slice(title, 0, title_length)}\n#{link}"
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