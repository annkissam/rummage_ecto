defmodule RummageEcto do
  @moduledoc """
  A module that provides Searching, Sorting and Paginating Ecto queries for Elixir applications.
  This also provides support for phoenix views and templates.

  ## Configuration
  ## Modules MyApp.Sort and MyApp.Search should implement RummageEcto.Hook behavior

    config :rummage_ecto, RummageEcto
      default_sort: MyApp.Sort,
      default_search: MyApp.Search,
      default_paginate: MyApp.Paginate

  """

  @doc false
  def default_search do
    config(:default_search, RummageEcto.Search)
  end

  @doc false
  def default_sort do
    config(:default_sort, RummageEcto.Sort)
  end

  def default_paginate do
    config(:default_paginate, RummageEcto.Paginate)
  end

  def per_page do
    config(:per_page, "10")
  end

  @doc false
  def config do
    Application.get_env(:rummage_ecto, RummageEcto, [])
  end

  @doc false
  def config(key, default \\ nil) do
    config()
    |> Keyword.get(key, default)
    |> resolve_config(default)
  end

  def rummage(query, rummage) do
    RummageEcto.Ecto.rummage(query, rummage)
  end

  defp resolve_config({:system, var_name}, default) do
    System.get_env(var_name) || default
  end

  defp resolve_config(value, _default), do: value
end
