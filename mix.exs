defmodule Rummage.Ecto.Mixfile do
  use Mix.Project

  @version "1.0.0"
  @url "https://github.com/Excipients/rummage_ecto"

  def project do
    [
      app: :rummage_ecto,
      version: @version,
      elixir: "~> 1.3",
      deps: deps(),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,

      # Test
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env),

      # Hex
      description: description(),
      package: package(),

      # Docs
      name: "Rumamge.Ecto",
      docs: docs(),
    ]
  end

  def application do
    [
      applications: [
        :logger,
        :ecto,
        :postgrex,
      ],
    ]
  end

  def package do
  [
    files: ["lib", "mix.exs", "README.md"],
    maintainers: ["Adi Iyengar"],
    licenses: ["MIT"],
    links: %{"Github" => @url},
  ]
end

  defp deps do
    [
      {:credo, "~> 0.5", only: [:dev, :test]},
      {:ecto, "~> 2.1"},
      {:excoveralls, "~> 0.3", only: :test},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:inch_ex, "~> 0.5", only: [:dev, :test, :docs]},
      {:postgrex, ">= 0.0.0", only: [:test]},
    ]
  end

  defp description do
    """
    A library that allows us to search, sort and paginate ecto queries
    """
  end

  def docs do
    [
      main: "Rummage.Ecto",
      source_url: "https://github.com/Excipients/rummage_ecto",
      extras: ["doc_readme.md", "CHANGELOG.md"],
      source_ref: "v#{@version}"
    ]
  end

  defp aliases do
    [
      "ecto.setup": [
        "ecto.create",
        "ecto.migrate"
      ],
     "ecto.reset": [
        "ecto.drop",
        "ecto.setup"
      ],
     "test": [
        # "ecto.drop",
        "ecto.create --quiet",
        "ecto.migrate",
        "test"
      ],
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "priv", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end
