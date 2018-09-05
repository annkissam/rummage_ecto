use Mix.Config

if Mix.env in ~w{test dev docs}a, do: import_config "#{Mix.env}.exs"

