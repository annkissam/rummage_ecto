defmodule Rummage.Ecto.Hooks.Paginate do
  @moduledoc ~S"""
  `Rummage.Ecto.Hooks.Paginate` is the default pagination hook that comes shipped
  with `Rummage`.

  This module can be overridden with a custom module while using `Rummage.Ecto`
  in `Ecto` struct module.
  """

  import Ecto.Query

  # @behaviour Rummage.Ecto.Hook

  @doc """
  Builds a paginate query on top of the given `query` from the rummage parameters
  from the given `rummage` struct.

  ## Examples
  When rummage struct passed doesn't have the key "paginate", it simply returns the
  query itself:

      iex> alias Rummage.Ecto.Hooks.Paginate
      iex> import Ecto.Query
      iex> Paginate.run(Parent, %{}, nil)
      Parent

  When the query passed is not just a struct:

      iex> alias Rummage.Ecto.Hooks.Paginate
      iex> import Ecto.Query
      iex> query = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Paginate.run(query, %{}, nil)
      #Ecto.Query<from p in "parents">

  When rummage struct passed has the key "paginate", with "per_page" and "page" keys
  it returns a paginated version of the query passed in as the argument:

      iex> alias Rummage.Ecto.Hooks.Paginate
      iex> import Ecto.Query
      iex> rummage = %{"paginate" => %{"per_page" => "1", "page" => "1"}}
      %{"paginate" => %{"page" => "1", "per_page" => "1"}}
      iex> query = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> Paginate.run(query, rummage, nil)
      #Ecto.Query<from p in "parents", limit: ^1, offset: ^0>
  """
  def run(query, rummage, repo) do
    paginate_params = Map.get(rummage, "paginate")

    case paginate_params do
      a when a in [nil, [], "", %{}] -> query
      _ -> handle_paginate(query, paginate_params, repo)
    end
  end

  defp handle_paginate(query, paginate_params, repo) do
    per_page = paginate_params
      |> Map.get("per_page")
      |> String.to_integer

    page = paginate_params
      |> Map.get("page", "1")
      |> String.to_integer

    total_count = case repo do
      nil -> nil
      _ -> query
      |> select([b], count(b.id))
      |> repo.one
    end

    per_page = if per_page < 1, do: 1, else: per_page

    max_page = case total_count do
      nil -> nil
      _ -> (total_count / per_page)
      |> Float.ceil
      |> round
    end

    page = cond do
      page < 1 ->  1
      max_page && page > max_page -> max_page
      true -> page
    end

    offset = per_page * (page - 1)

    query
    |> limit(^per_page)
    |> offset(^offset)
  end
end
