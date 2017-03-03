use Mix.Config

config :logger, level: :warn

config :rummage_ecto, Rummage.Ecto,[
  default_repo: Rummage.Ecto.Repo,
  default_per_page: 2,
]

config :rummage_ecto, ecto_repos: [Rummage.Ecto.Repo]

config :rummage_ecto, Rummage.Ecto.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "",
  database: "rummage_ecto_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
