defmodule Rummage.Ecto.Config do
  @moduledoc false

  @doc false
  def default_search do
    config(:default_search, Rummage.Ecto.Hooks.Search)
  end

  @doc false
  def default_sort do
    config(:default_sort, Rummage.Ecto.Hooks.Sort)
  end

  @doc false
  def default_paginate do
    config(:default_paginate, Rummage.Ecto.Hooks.Paginate)
  end

  @doc false
  def default_per_page do
    config(:default_per_page, "10")
  end

  @doc false
  defp config do
    Application.get_env(:rummage_ecto, Rummage.Ecto, [])
  end

  @doc false
  defp config(key, default) do
    config()
    |> Keyword.get(key, default)
    |> resolve_config(default)
  end

  @doc false
  defp resolve_config({:system, var_name}, default) do
    System.get_env(var_name) || default
  end

  @doc false
  defp resolve_config(value, _default), do: value
end
