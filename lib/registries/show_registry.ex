defmodule CachedBandsintown.ShowRegistry do 
	use GenServer
	require Logger

	alias CachedBandsintown.RequestHandler

	@auto_update Application.get_env(:cached_bandsintown, :auto_update, false)
	@update_interval Application.get_env(:cached_bandsintown, :update_interval, 1 * 60 * 60 * 10000)

	# Add request here
	def get_items do
		RequestHandler.get_shows()
	end

	def start_link(name) do
		GenServer.start_link(__MODULE__, :ok, name: name)
	end

	def init(:ok) do
		if @auto_update, do: schedule_work()
		itemData = get_items()
		{:ok, itemData}
	end

	# Auto updater
	defp schedule_work do
		Process.send_after(self(), :work, @update_interval)
	end

	def handle_info(:work, state) do 
    	items = get_items()
		GenServer.cast(__MODULE__, {:updateItems, items})
    	schedule_work()
	    {:noreply, state}
	 end

	# Getters
	def handle_call(:getItems, _from, itemData) do
		case itemData do
			items -> 
				{:reply, items, items}
			# {:error, nil} -> 
			# 	{:reply, %{}, {:error, nil}}
		end
	end

	# Updates
	def handle_cast({:updateItems, items}, _assetData) do
		{:noreply, items}
	end

end