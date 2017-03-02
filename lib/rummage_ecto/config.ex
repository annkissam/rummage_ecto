defmodule Rummage.Ecto.Config do
  @moduledoc """
  This module encapsulates all the Rummage's runtime configurations
  that can be set in the config.exs file.
  """

  @doc """
  `:default_search` hook can also be set at run time
  in the config.exs file
  """
  def default_search do
    config(:default_search, Rummage.Ecto.Hooks.Search)
  end

  @doc """
  `:default_sort` hook can also be set at run time
  in the config.exs file
  """
  def default_sort do
    config(:default_sort, Rummage.Ecto.Hooks.Sort)
  end

  @doc """
  `:default_paginate` hook can also be set at run time
  in the config.exs file
  """
  def default_paginate do
    config(:default_paginate, Rummage.Ecto.Hooks.Paginate)
  end

  @doc """
  `:default_per_page` hook can also be set at run time
  in the config.exs file
  """
  def default_per_page do
    config(:default_per_page, "10")
  end

  @doc """
  `:default_repo` hook can also be set at run time
  in the config.exs file
  """
  def default_repo do
    config(:default_repo, nil)
  end

  defp config do
    Application.get_env(:rummage_ecto, Rummage.Ecto, [])
  end

  defp config(key, default) do
    config()
    |> Keyword.get(key, default)
    |> resolve_config(default)
  end

  defp resolve_config({:system, var_name}, default) do
    System.get_env(var_name) || default
  end

  defp resolve_config(value, _default), do: value
end
