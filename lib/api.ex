defmodule CachedBandsintown.Api do 

	use Timex
	alias CachedBandsintown.RequestHandler

	# SHOWS
	def get_all_shows do
		case GenServer.call(CachedBandsintown.ShowRegistry, :getItems) do
	      {:ok, shows: shows} ->
	        shows
	      {:error, message: message} ->
	        message
	    end
	end

	def get_past_shows do
		case GenServer.call(CachedBandsintown.ShowRegistry, :getItems) do
	      {:ok, shows: shows} ->
	        shows
				|> Enum.filter(fn(show) -> 
					Timex.before?(show.datetime,Timex.today)
				end)
	      {:error, message: message} ->
	        message
	    end
	end

	def get_upcoming_shows do
		case GenServer.call(CachedBandsintown.ShowRegistry, :getItems) do
	      {:ok, shows: shows} ->
	        shows
				|> Enum.filter(fn(show) -> 
					Timex.after?(show.datetime,Timex.today)
				end)
	      {:error, message: message} ->
	        message
	    end
	end

	# ARTIST
	def getArtist do
		GenServer.call(CachedBandsintown.ArtistRegistry, :getItems)
	end


	# UPDATERS
	def updateShows do
		items = RequestHandler.get_shows()
		GenServer.cast(CachedBandsintown.ShowRegistry, {:updateItems, items})
	end

	def updateArtist do
		items = RequestHandler.get_artist()
		GenServer.cast(CachedBandsintown.ArtistRegistry, {:updateItems, items})
	end

end