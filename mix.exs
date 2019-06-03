defmodule Rummage.Ecto.Mixfile do
  use Mix.Project

  @version "2.0.0-rc.0"
  @elixir "~> 1.6"
  @url "https://github.com/annkissam/rummage_ecto"

  def project do
    [
      app: :rummage_ecto,
      version: @version,
      elixir: @elixir,
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
      name: "Rummage.Ecto",
      docs: docs(),
    ]
  end

  def application do
    [
      applications: [
        :logger,
        :ecto,
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
      # Development Dependency
      {:ecto, "~> 2.2"},

      # Other Dependencies
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.8", only: :test, runtime: false},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:inch_ex, "~> 0.5", only: [:dev, :test, :docs], runtime: false},
      {:postgrex, "~> 0.13", only: :test, optional: true, runtime: false},
    ]
  end

  defp description do
    """
    A library that allows searching, sorting and paginating ecto queries
    """
  end

  def docs do
    [
      main: "Rummage.Ecto",
      source_url: @url,
      extras: ["README.md",
               "CHANGELOG.md",
               "help/nomenclature.md",
               "help/walkthrough.md"],
      source_ref: "v#{@version}"
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.setup --quite", "test"],
      "test.watch.stale": &test_watch_stale/1,
    ]
  end

  defp test_watch_stale(_) do
    System.cmd(
      "sh",
      ["-c", "#{get_system_watcher()} lib/ test/ | mix test --stale --listen-on-stdin"],
      into: IO.stream(:stdio, :line)
    )
  end

  # Works only for Mac and Linux
  defp get_system_watcher do
    case System.cmd("uname", []) do
      {"Linux\n", 0} -> "inotifywait -e modify -e create -e delete -mr" # For Linux systems inotify should work
      {"Darwin\n", 0} -> "fswatch" # For Macs, fswatch comes directly installed
      {kernel, 0} -> raise "Watcher not supported on kernel: #{kernel}"
    end
  end

  defp elixirc_paths(:test), do: ["lib", "priv", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end
