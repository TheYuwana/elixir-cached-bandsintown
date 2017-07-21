defmodule CachedBandsintown.RequestHandler do 

  use Timex

  @baseUrl "http://api.bandsintown.com/artists/"
  @apiKey Application.get_env(:cached_bandsintown, :api_key, "elixir_cached_bandsintown") 
  @artist Application.get_env(:cached_bandsintown, :artist, "")

  def get_artist do
    type = "/events.json?api_version=2.0"
    url = "#{@baseUrl}#{@artist}#{type}&app_id=#{@apiKey}"
    process_request(url, "artist")
  end

  def get_shows do
    type = "/events.json?api_version=2.0"
    apiKey = "&app_id=#{@apiKey}"

    today = Timex.today
    nextYear = Timex.shift(today, years: 1)
    minDate = "1960-01-01"
    maxDate = "#{nextYear.year}-#{leading_zero(nextYear.month)}-#{leading_zero(nextYear.day)}"

    criteria = "&date=#{minDate},#{maxDate}"
    url = "#{@baseUrl}#{@artist}#{type}#{criteria}&app_id=#{@apiKey}"
    process_request(url, "shows")
  end

  defp leading_zero(number) do
    if number < 10 do
      "0#{number}"  
    else
      "#{number}"
    end
  end

  defp datetime_from_iso(isotime) do
    case DateTime.from_iso8601(isotime) do
      {:ok, dt, _}  -> dt
      _             -> nil
    end
  end

  defp key_string_to_atom(list) do
    for {key, val} <- list, into: %{}, do: {String.to_atom(key), val}
  end

  defp process_artist(body) do
    # json decode response
    body |> Poison.decode!
      |> key_string_to_atom()
  end

  defp process_shows(body) do
    # json decode response
    body |> Poison.decode!
      |> Enum.map(fn(show)->
        # show is each single item in the list
        # compare current map with artist to see if exist and filter only selected here
        %{
          "artist_event_id" => event_id,
          "title" => title,
          "description" => description,
          "datetime" => datetime,
          "artists" => artists,
          "venue" => venue
        } = show

        # create and return new map with the checked values form above
         datetime = datetime <> "Z"
          |> datetime_from_iso()

        %{
          event_id: event_id,
          title: title,
          description: description,
          datetime: datetime,
          venue: %{
            place: venue["place"],
            city: venue["city"],
            country: venue["country"]
          }
        }
    end)
  end

  defp process_request(url, process) do
    case HTTPoison.get(url) do 
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        # Do something if success

        body = case process do
          "shows" -> process_shows(body)
          "artist" -> process_artist(body)
        end
        
        {:ok, shows: body}      
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        # Item not found
        {:missing, message: "Unkown Artist"} 
      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        # Do something if seomthing server side happened
        {:error, message: "Error code: #{code}, message: #{body}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        # Something wrong happened
        {:error, message: "Something went wrong! Reason: #{reason}"}
    end
  end

end