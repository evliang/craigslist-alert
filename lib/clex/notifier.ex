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

    #prioritize the link and truncate the title in order to fit into one text
    defp title_and_link_msg(title, link, offset \\ 0) do
        # 160: twilio limit for SMS. 2: for newline
        title_length = 160 - offset - 2 - String.length(link)
        if is_trial_account() do
            title_length = title_length - 37 # SMS from trial accounts contain 37 chars of additional text
        end
        "#{String.slice(title, 0, title_length)}\n#{link}"
    end

    defp is_trial_account() do
        Application.get_env(:clex, :twilio_trial, true)
    end

    defp send_message(msg) do
        SmsBlitz.send_sms(
            :twilio,
            from: Application.get_env(:clex, :twilio_sender),
            to: Application.get_env(:clex, :twilio_recip),
            message: msg)
    end

    defp handle_blitz_response(lst) when is_list(lst) do
        lst
        |> Enum.each(&handle_blitz_response(&1))
    end

    #SmsBlitz isn't the ideal library for errors
    #one of my phones doesn't allow texts. Twilio returned an error code but SmsBlitz returned 200
    defp handle_blitz_response(%{id: _i, result_string: _r, status_code: _sc} = map) do
        IO.inspect map
    end
end