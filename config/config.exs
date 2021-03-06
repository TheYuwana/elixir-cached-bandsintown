# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :cached_bandsintown,
	artist: "DEFAZER",
	api_key: "elixir_cached_bandsintown",
	auto_update: false,
	update_interval: 24 * 60 * 60 * 1000 # Refresh every 24 hours (milliseconds)