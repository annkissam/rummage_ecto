use Mix.Config

config :logger, :console,
  level: :error

config :rummage_ecto, Rummage.Ecto,
  repo: Rummage.Ecto.Repo,
  per_page: 2

config :rummage_ecto, ecto_repos: [Rummage.Ecto.Repo]

config :rummage_ecto, Rummage.Ecto.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("POSTGRES_USER"),
  password: System.get_env("POSTGRES_PASSWORD"),
  database: "rummage_ecto_test",
  pool: Ecto.Adapters.SQL.Sandbox
