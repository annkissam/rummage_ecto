defmodule RummageEcto.Mixfile do
  use Mix.Project

  @version "0.1.0"

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
      name: "Rumamge Ecto",
      docs: [
        main: "Rummage Ecto",
        canonical: "http://hexdocs.pm/rummage_ecto",
        source_url: "https://github.com/Excipients/rummage_ecto",
      ]
    ]
  end

  def application do
    [
      applications: [
        :logger,
        :phoenix,
        :phoenix_ecto,
        :phoenix_html
      ]
    ]
  end

  def package do
  [
    name: :rummage_ecto,
    files: ["lib", "mix.exs"],
    maintainers: ["Adi Iyengar"],
    licenses: ["MIT"],
    links: %{"Github" => "https://github.com/Excipients/rummage_ecto"},
  ]
end

  defp deps do
    [
      {:ecto, "~> 2.1"},
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end

  defp description do
    """
    A simple library that allows us to search, sort and paginate ecto queries
    """
  end
end
