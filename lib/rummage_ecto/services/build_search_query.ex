defmodule Rummage.Ecto.Services.BuildSearchQuery do
  @moduledoc """
  `Rummage.Ecto.Services.BuildSearchQuery` is a service module which serves the
  default search hook, `Rummage.Ecto.Hooks.Search` that comes shipped with `Rummage.Ecto`.

  Has a `Module Attribute` called `search_types`:

  ```elixir
  @search_types ~w(like ilike eq gt lt gteq lteq)
  ```

  `@search_types` is a collection of all the 7 valid `search_types` that come shipped with
  `Rummage.Ecto`'s default search hook. The types are:

  * `like`: Searches for a `term` in a given `field` of a `queryable`.
  * `ilike`: Searches for a `term` in a given `field` of a `queryable`, in a case insensitive fashion.
  * `eq`: Searches for a `term` to be equal to a given `field` of a `queryable`.
  * `gt`: Searches for a `term` to be greater than to a given `field` of a `queryable`.
  * `lt`: Searches for a `term` to be less than to a given `field` of a `queryable`.
  * `gteq`: Searches for a `term` to be greater than or equal to to a given `field` of a `queryable`.
  * `lteq`: Searches for a `term` to be less than or equal to a given `field` of a `queryable`.

  Feel free to use this module on a custom search hook that you write.
  """

  import Ecto.Query

  @search_types ~w(like ilike eq gt lt gteq lteq)

  @spec run(Ecto.Query.t, atom, String.t, term) :: {Ecto.Query.t}
  def run(queryable, field, search_type, search_term) do
    case Enum.member?(@search_types, search_type) do
      true -> apply(__MODULE__, String.to_atom("handle_" <> search_type), [queryable, field, search_term])
      _ -> queryable
    end
  end

  def handle_like(queryable, field, search_term) do
    queryable
    |> where([..., b],
      like(field(b, ^field), ^"%#{String.replace(search_term, "%", "\\%")}%"))
  end

  def handle_ilike(queryable, field, search_term) do
    queryable
    |> where([..., b],
      ilike(field(b, ^field), ^"%#{String.replace(search_term, "%", "\\%")}%"))
  end

  def handle_eq(queryable, field, search_term) do
    queryable
    |> where([..., b],
      field(b, ^field) == ^search_term)
  end

  def handle_gt(queryable, field, search_term) do
    queryable
    |> where([..., b],
      field(b, ^field) > ^search_term)
  end

  def handle_lt(queryable, field, search_term) do
    queryable
    |> where([..., b],
      field(b, ^field) < ^search_term)
  end

  def handle_gteq(queryable, field, search_term) do
    queryable
    |> where([..., b],
      field(b, ^field) >= ^search_term)
  end

  def handle_lteq(queryable, field, search_term) do
    queryable
    |> where([..., b],
      field(b, ^field) <= ^search_term)
  end
end
