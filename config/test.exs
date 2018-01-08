use Mix.Config

config :logger, :console,
  level: :error

config :rummage_ecto, Rummage.Ecto,[
  repo: Rummage.Ecto.Repo,
  per_page: 2,
]

config :rummage_ecto, ecto_repos: [Rummage.Ecto.Repo]

config :rummage_ecto, Rummage.Ecto.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "rummage_ecto_test.sqlite3",
  pool: Ecto.Adapters.SQL.Sandbox
