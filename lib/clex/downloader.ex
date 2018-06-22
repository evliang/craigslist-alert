defmodule Clex.Downloader do

    def download_rss(%{"category" => category, "city" => city, "keywords" => keywords}) do
        keyword_string =
            keywords
            |> Enum.map(fn x -> "\"#{x |> String.split(" ") |> Enum.join("+")}\"" end)
            |> Enum.join("+")
        "https://#{city}.craigslist.org/search/#{category}?format=rss&query=#{keyword_string}"
        |> get_url
    end
    
    defp get_url(url) do
        url
        |> URI.encode
        |> String.replace("%25", "%") #in case we're already dealing with %20, etc in URL
        |> get_poison
    end
    
    defp get_poison(url) do
        try do
          HTTPoison.get(url,
            ["User-Agent": "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.139 Mobile Safari/537.36",
            "Content-Type": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8"],
            [follow_redirect: true ])
          |> handle_poison
        rescue
          e -> {:error, "Error fetching info from site"}
        end
    end
    
    defp handle_poison({:ok, %HTTPoison.Response{} = resp}) do
        gzipped = Enum.any?(resp.headers, fn (kv) ->
            case kv do
                {"Content-Encoding", "gzip"} -> true
                {"Content-Encoding", "x-gzip"} -> true
                _ -> false
            end
        end)
    
        if gzipped do
            %{resp | body: :zlib.gunzip(resp.body)}
        else
            resp
        end
    end
    
    defp handle_poison(e) do
        IO.inspect e, label: "error handling poison"
        {:error, "Error when fetching data"}
    end
end