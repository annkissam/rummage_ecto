defmodule Rummage.Ecto.Config do
  @moduledoc """
  This module encapsulates all the Rummage's runtime configurations
  that can be set in the config.exs file.

  __This configuration is optional, as `Rummage.Ecto` can accept the same
  arguments as optional arguments to the function `Rummage.Ecto.rummage/3`__

  ## Usage:

  A basic example without overriding default hooks:
  ### config.exs:

    config :app_name, Rummage.Ecto,
      per_page: 10,
      repo: AppName.Repo

  This is a more advanced usage where you can specify the default hooks:
  ### config.exs:

    config :app_name, Rummage.Ecto,
      per_page: 10,
      repo: AppName.Repo,
      search: Rummage.Ecto.Hook.Search,
      sort: Rummage.Ecto.Hook.Sort,
      paginate: Rummage.Ecto.Hook.Paginate

  """

  @doc """
  `:search` hook can also be set at run time
  in the `config.exs` file. This pulls the configuration
  assocated with the application, `application`. When no
  application is given this defaults to `rummage_ecto`.

  ## Examples
  When no config is set, if returns the default hook
  (`Rummage.Ecto.Hook.Search`):
      iex> alias Rummage.Ecto.Config
      iex> Config.search
      Rummage.Ecto.Hook.Search
  """
  def search(application \\ :rummage_ecto) do
    config(:search, Rummage.Ecto.Hook.Search, application)
  end

  @doc """
  `:sort` hook can also be set at run time
  in the `config.exs` file

  ## Examples
  When no config is set, if returns the default hook
  (`Rummage.Ecto.Hook.Sort`):
      iex> alias Rummage.Ecto.Config
      iex> Config.sort
      Rummage.Ecto.Hook.Sort
  """
  def sort(application \\ :rummage_ecto) do
    config(:sort, Rummage.Ecto.Hook.Sort, application)
  end

  @doc """
  `:paginate` hook can also be set at run time
  in the `config.exs` file

  ## Examples
  When no config is set, if returns the default hook
  (`Rummage.Ecto.Hook.Paginate`):
      iex> alias Rummage.Ecto.Config
      iex> Config.paginate
      Rummage.Ecto.Hook.Paginate
  """
  def paginate(application \\ :rummage_ecto) do
    config(:paginate, Rummage.Ecto.Hook.Paginate, application)
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
  def per_page(application \\ :rummage_ecto) do
    config(:per_page, 10, application)
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
  def repo(application \\ :rummage_ecto) do
    config(:repo, nil, application)
  end

  defp config(application) do
    Application.get_env(application, Rummage.Ecto, [])
  end

  defp config(key, default, application) do
    application
    |> config()
    |> Keyword.get(key, default)
    |> resolve_config(default)
  end

  defp resolve_config(value, _default), do: value
end
