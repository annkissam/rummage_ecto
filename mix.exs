defmodule RummageEcto.Mixfile do
  use Mix.Project

  def project do
    [
      app: :rummage_ecto,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      package: package,
      deps: deps
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
    ]
  end
end
