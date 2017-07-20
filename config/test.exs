use Mix.Config

config :logger, :console,
  level: :error

config :rummage_ecto, Rummage.Ecto,[
  default_repo: Rummage.Ecto.Repo,
  default_per_page: 2,
]

config :rummage_ecto, ecto_repos: [Rummage.Ecto.Repo]

config :rummage_ecto, Rummage.Ecto.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("ECTO_PGSQL_USER"),
  password: System.get_env("ECTO_PGSQL_PASSWORD"),
  database: "rummage_ecto_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
