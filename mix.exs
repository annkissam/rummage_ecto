defmodule Rummage.Ecto.Mixfile do
  use Mix.Project

  @version "0.1.1"
  @url "https://github.com/Excipients/rummage_ecto"

  def project do
    [
      app: :rummage_ecto,
      version: @version,
      elixir: "~> 1.4",
      deps: deps(),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,

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
    name: :rummage_ecto,
    files: ["lib", "mix.exs"],
    maintainers: ["Adi Iyengar"],
    licenses: ["MIT"],
    links: %{"Github" => @url},
  ]
end

  defp deps do
    [
      {:ecto, "~> 2.1"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:postgrex, ">= 0.0.0", only: [:test, :doc]},
    ]
  end

  defp description do
    """
    A simple library that allows us to search, sort and paginate ecto queries
    """
  end

  def docs do
    [
      source_url: "https://github.com/Excipients/rummage_ecto",
      extras: ["README.md"],
      source_ref: "v#{@version}"
    ]
  end
end
