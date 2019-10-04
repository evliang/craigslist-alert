defmodule Clex.Notifier do
    require Logger

    def notify() do
        Redix.command!(:redix, ["LPOP", "notifs"])
        |> handle_redis_response
    end

    defp handle_redis_response(nil), do: nil

    defp handle_redis_response(binary) do
        binary
        |> :erlang.binary_to_term
        |> IO.inspect
        |> create_message
        |> send_message
        |> handle_blitz_response
    end

    defp create_message(%{price: price, title: title, link: link} = info) do
        price_len = String.length("#{price}")
        info
        |> Map.put(:message, "$#{price} - #{title_and_link_msg(title, link, price_len + 4)}")
    end

    defp create_message(%{title: title, link: link} = info) do
        Map.put(info, :message, title_and_link_msg(title, link))
    end

    #prioritize the link and truncate the title in order to fit into one text
    def title_and_link_msg(title, link, offset \\ 0) do
        # todo: fix - hardcoding all over. 160: twilio limit for SMS. 2: for newline. 37: SMS from trial accounts contain 37 chars of additional text
        title_length =
            if is_trial_account() do
                160 - offset - 2 - String.length(link)
            else
                160 - offset - 2 - String.length(link) - 37
            end
        "#{String.slice(title, 0, title_length)}\n#{link}"
    end

    defp is_trial_account() do
        Application.get_env(:clex, :twilio_trial, true)
    end

    defp send_message(info) do
        msg = Map.get(info, :message)
        Logger.debug(msg)
        SmsBlitz.send_sms(
            :twilio,
            from: Application.get_env(:clex, :twilio_sender),
            to: Map.get(info, :phone_num, Application.get_env(:clex, :twilio_recip)),
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