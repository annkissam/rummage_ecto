defmodule Rummage.Ecto.Config do
  @moduledoc """
  This module encapsulates all the Rummage's runtime configurations
  that can be set in the config.exs file.
  """

  @doc """
  `:default_search` hook can also be set at run time
  in the `config.exs` file

  ## Examples
  When no config is set, if returns the default hook
  (`Rummage.Ecto.Hooks.Search`):
      iex> alias Rummage.Ecto.Config
      iex> Config.default_search
    Rummage.Ecto.Hooks.Search
  """
  def default_search do
    config(:default_search, Rummage.Ecto.Hooks.Search)
  end

  @doc """
  `:default_sort` hook can also be set at run time
  in the `config.exs` file

  ## Examples
  When no config is set, if returns the default hook
  (`Rummage.Ecto.Hooks.Sort`):
      iex> alias Rummage.Ecto.Config
      iex> Config.default_sort
    Rummage.Ecto.Hooks.Sort
  """
  def default_sort do
    config(:default_sort, Rummage.Ecto.Hooks.Sort)
  end

  @doc """
  `:default_paginate` hook can also be set at run time
  in the `config.exs` file

  ## Examples
  When no config is set, if returns the default hook
  (`Rummage.Ecto.Hooks.Paginate`):
      iex> alias Rummage.Ecto.Config
      iex> Config.default_paginate
    Rummage.Ecto.Hooks.Paginate
  """
  def default_paginate do
    config(:default_paginate, Rummage.Ecto.Hooks.Paginate)
  end

  @doc """
  `:default_per_page` hook can also be set at run time
  in the `config.exs` file

  ## Examples
  Returns default `Repo` set in the config
  (`2 in `rummage_ecto`'s test env):
      iex> alias Rummage.Ecto.Config
      iex> Config.default_per_page
    2
  """
  def default_per_page do
    config(:default_per_page, 10)
  end

  @doc """
  `:default_repo` hook can also be set at run time
  in the config.exs file

  ## Examples
  Returns default `Repo` set in the config
  (`Rummage.Ecto.Repo` in `rummage_ecto`'s test env):
      iex> alias Rummage.Ecto.Config
      iex> Config.default_repo
    Rummage.Ecto.Repo
  """
  def default_repo do
    config(:default_repo, nil)
  end

  @doc """
  `resolve_system_config` returns a system variable set up or returns the
  specified default value

  ## Examples
  Returns value corresponding to a system variable config or returns the default value:
      iex> alias Rummage.Ecto.Config
      iex> Config.resolve_system_config({:system, "some random config"}, "default")
    "default"
  """
  @spec resolve_system_config(Tuple.t, term) :: {term}
  def resolve_system_config({:system, var_name}, default) do
    System.get_env(var_name) || default
  end

  defp config do
    Application.get_env(:rummage_ecto, Rummage.Ecto, [])
  end

  defp config(key, default) do
    config()
    |> Keyword.get(key, default)
    |> resolve_config(default)
  end

  defp resolve_config(value, _default), do: value
end
