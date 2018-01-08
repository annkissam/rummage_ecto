defmodule Rummage.Ecto.Config do
  @moduledoc """
  This module encapsulates all the Rummage's runtime configurations
  that can be set in the config.exs file.
  """

  @doc """
  `:search` hook can also be set at run time
  in the `config.exs` file

  ## Examples
  When no config is set, if returns the default hook
  (`Rummage.Ecto.Hooks.Search`):
      iex> alias Rummage.Ecto.Config
      iex> Config.search
      Rummage.Ecto.Hooks.Search
  """
  def search do
    config(:search, Rummage.Ecto.Hooks.Search)
  end

  @doc """
  `:sort` hook can also be set at run time
  in the `config.exs` file

  ## Examples
  When no config is set, if returns the default hook
  (`Rummage.Ecto.Hooks.Sort`):
      iex> alias Rummage.Ecto.Config
      iex> Config.sort
      Rummage.Ecto.Hooks.Sort
  """
  def sort do
    config(:sort, Rummage.Ecto.Hooks.Sort)
  end

  @doc """
  `:paginate` hook can also be set at run time
  in the `config.exs` file

  ## Examples
  When no config is set, if returns the default hook
  (`Rummage.Ecto.Hooks.Paginate`):
      iex> alias Rummage.Ecto.Config
      iex> Config.paginate
      Rummage.Ecto.Hooks.Paginate
  """
  def paginate do
    config(:paginate, Rummage.Ecto.Hooks.Paginate)
  end

  @doc """
  `:per_page` can also be set at run time
  in the `config.exs` file

  ## Examples
  Returns default `Repo` set in the config
  (`2 in `rummage_ecto`'s test env):
      iex> alias Rummage.Ecto.Config
      iex> Config.per_page
      2
  """
  def per_page do
    config(:per_page, 10)
  end

  @doc """
  `:repo` can also be set at run time
  in the config.exs file

  ## Examples
  Returns default `Repo` set in the config
  (`Rummage.Ecto.Repo` in `rummage_ecto`'s test env):
      iex> alias Rummage.Ecto.Config
      iex> Config.repo
      Rummage.Ecto.Repo
  """
  def repo do
    config(:repo, nil)
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
