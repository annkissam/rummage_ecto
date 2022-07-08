import Config

env = config_env()
if env in ~w(test dev docs)a, do: import_config "#{env}.exs"
