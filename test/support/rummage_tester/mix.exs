defmodule RummageTester.MixProject do
  use Mix.Project

  def project do
    [
      app: :rummage_tester,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env),
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :rummage_ecto, :postgrex],
      mod: {RummageTester.Application, []}
    ]
  end

  defp deps do
    [
      {:rummage_ecto, path: "../../../"},
      {:postgrex, "~> 0.13", only: :test, optional: true, runtime: false},
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.setup --quite", "test", "coveralls"],
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "priv", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end
