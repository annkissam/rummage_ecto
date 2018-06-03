use Mix.Config

config :rummage_tester,
  ecto_repos: [RummageTester.Repo]

config :rummage_tester, Rummage.Ecto,
  repo: RummageTester.Repo,
  per_page: 10

case Mix.env() do
  :test ->
    config :rummage_tester, RummageTester.Repo,
      adapter: Ecto.Adapters.Postgres,
      database: "rummage_tester_repo_test",
      username: System.get_env("POSTGRES_USER"),
      password: System.get_env("POSTGRES_PASSWORD"),
      pool: Ecto.Adapters.SQL.Sandbox
  :dev ->
    config :rummage_tester, RummageTester.Repo,
      adapter: Ecto.Adapters.Postgres,
      database: "rummage_tester_repo_dev",
      username: System.get_env("POSTGRES_USER"),
      password: System.get_env("POSTGRES_PASSWORD")
end
