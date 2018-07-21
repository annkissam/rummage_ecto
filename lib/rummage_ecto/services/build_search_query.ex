defmodule Rummage.Ecto.Services.BuildSearchQuery do
  @moduledoc """
  `Rummage.Ecto.Services.BuildSearchQuery` is a service module which serves the
  default search hook, `Rummage.Ecto.Hooks.Search` that comes shipped with `Rummage.Ecto`.

  Has a `Module Attribute` called `search_types`:

  ```elixir
  @search_types ~w(like ilike eq gt lt gteq lteq is_nil)
  ```

  `@search_types` is a collection of all the 8 valid `search_types` that come shipped with
  `Rummage.Ecto`'s default search hook. The types are:

  * `like`: Searches for a `term` in a given `field` of a `queryable`.
  * `ilike`: Searches for a `term` in a given `field` of a `queryable`, in a case insensitive fashion.
  * `eq`: Searches for a `term` to be equal to a given `field` of a `queryable`.
  * `gt`: Searches for a `term` to be greater than to a given `field` of a `queryable`.
  * `lt`: Searches for a `term` to be less than to a given `field` of a `queryable`.
  * `gteq`: Searches for a `term` to be greater than or equal to to a given `field` of a `queryable`.
  * `lteq`: Searches for a `term` to be less than or equal to a given `field` of a `queryable`.
  * `is_nil`: Searches for a `term` to be nil or not nil to a given `field` of a `queryable`.
  * `between`: Searches for a `term` to be in range `field_1` and `field_2` of a `queryable`.

  Feel free to use this module on a custom search hook that you write.
  """

  import Ecto.Query

  @search_types ~w(like ilike eq gt lt gteq lteq is_nil in nin between)

  @doc """
  Builds a searched `queryable` on top of the given `queryable` using `field`, `search_type`
  and `search_term`.

  ## Examples
  When `field`, `search_type` and `queryable` are passed with `search_type` of `like`:

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.run(queryable, :field_1, "like", "field_!")
      #Ecto.Query<from p in "parents", where: like(p.field_1, ^"field_!")>

  When `field`, `search_type` and `queryable` are passed with `search_type` of `ilike`:

        iex> alias Rummage.Ecto.Services.BuildSearchQuery
        iex> import Ecto.Query
        iex> queryable = from u in "parents"
        #Ecto.Query<from p in "parents">
        iex> BuildSearchQuery.run(queryable, :field_1, "ilike", "field_!")
        #Ecto.Query<from p in "parents", where: ilike(p.field_1, ^"field_!")>

  When `field`, `search_type` and `queryable` are passed with `search_type` of `eq`:

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.run(queryable, :field_1, "eq", "field_!")
      #Ecto.Query<from p in "parents", where: p.field_1 == ^"field_!">

  When `field`, `search_type` and `queryable` are passed with `search_type` of `gt`:

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.run(queryable, :field_1, "gt", "field_!")
      #Ecto.Query<from p in "parents", where: p.field_1 > ^"field_!">

  When `field`, `search_type` and `queryable` are passed with `search_type` of `lt`:

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.run(queryable, :field_1, "lt", "field_!")
      #Ecto.Query<from p in "parents", where: p.field_1 < ^"field_!">

  When `field`, `search_type` and `queryable` are passed with `search_type` of `gteq`:

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.run(queryable, :field_1, "gteq", "field_!")
      #Ecto.Query<from p in "parents", where: p.field_1 >= ^"field_!">

  When `field`, `search_type` and `queryable` are passed with `search_type` of `lteq`:

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.run(queryable, :field_1, "lteq", "field_!")
      #Ecto.Query<from p in "parents", where: p.field_1 <= ^"field_!">

  When `field`, `search_type` and `queryable` are passed with `search_type` of `is_nil`:

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.run(queryable, :field_1, "is_nil", "false")
      #Ecto.Query<from p in "parents", where: not is_nil(p.field_1)>

  When `field`, `search_type` and `queryable` are passed with `search_type` of `in`:

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.run(queryable, :field_1, "in", ["1", "2"])
      #Ecto.Query<from p in "parents", where: p.field_1 in ^["1", "2"]>

  When `field`, `search_type` and `queryable` are passed with `search_type` of `nin`:

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.run(queryable, :field_1, "nin", ["1", "2"])
      #Ecto.Query<from p in "parents", where: p.field_1 not in ^["1", "2"]>

  When `field`, `search_type` and `queryable` are passed with `search_type` of `nin`:

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.run(queryable, :field_1, "between", ["1", "2"])
      #Ecto.Query<from p in "parents", where: p.field_1 >= ^"1", where: p.field_1 <= ^"2">

  When `field`, `search_type` and `queryable` are passed with an invalid `search_type`:

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.run(queryable, :field_1, "pizza", "field_!")
      #Ecto.Query<from p in "parents">

  """
  @spec run(Ecto.Query.t(), atom, String.t(), term) :: {Ecto.Query.t()}
  def run(queryable, field, search_type, search_term) do
    case Enum.member?(@search_types, search_type) do
      true ->
        apply(__MODULE__, String.to_atom("handle_" <> search_type), [
          queryable,
          field,
          search_term
        ])

      _ ->
        queryable
    end
  end

  @doc """
  Builds a searched `queryable` on top of the given `queryable` using `field` and `search_type`
  when the `search_term` is `like`.

  ## Examples

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_like(queryable, :field_1, "field_!")
      #Ecto.Query<from p in "parents", where: like(p.field_1, ^"field_!")>
  """
  @spec handle_like(Ecto.Query.t(), atom, term) :: {Ecto.Query.t()}
  def handle_like(queryable, field, search_term) do
    queryable
    |> where([..., b], like(field(b, ^field), ^search_term))
  end

  @doc """
  Builds a searched `queryable` on top of the given `queryable` using `field` and `search_type`
  when the `search_term` is `ilike`.

  ## Examples

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_ilike(queryable, :field_1, "field_!")
      #Ecto.Query<from p in "parents", where: ilike(p.field_1, ^"field_!")>
  """
  @spec handle_ilike(Ecto.Query.t(), atom, term) :: {Ecto.Query.t()}
  def handle_ilike(queryable, field, search_term) do
    queryable
    |> where([..., b], ilike(field(b, ^field), ^search_term))
  end

  @doc """
  Builds a searched `queryable` on top of the given `queryable` using `field` and `search_type`
  when the `search_term` is `eq`.

  ## Examples

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_eq(queryable, :field_1, "field_!")
      #Ecto.Query<from p in "parents", where: p.field_1 == ^"field_!">
  """
  @spec handle_eq(Ecto.Query.t(), atom, term) :: {Ecto.Query.t()}
  def handle_eq(queryable, field, search_term) do
    queryable
    |> where([..., b], field(b, ^field) == ^search_term)
  end

  @doc """
  Builds a searched `queryable` on top of the given `queryable` using `field` and `search_type`
  when the `search_term` is `gt`.

  ## Examples

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_gt(queryable, :field_1, "field_!")
      #Ecto.Query<from p in "parents", where: p.field_1 > ^"field_!">
  """
  @spec handle_gt(Ecto.Query.t(), atom, term) :: {Ecto.Query.t()}
  def handle_gt(queryable, field, search_term) do
    queryable
    |> where([..., b], field(b, ^field) > ^search_term)
  end

  @doc """
  Builds a searched `queryable` on top of the given `queryable` using `field` and `search_type`
  when the `search_term` is `lt`.

  ## Examples

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_lt(queryable, :field_1, "field_!")
      #Ecto.Query<from p in "parents", where: p.field_1 < ^"field_!">
  """
  @spec handle_lt(Ecto.Query.t(), atom, term) :: {Ecto.Query.t()}
  def handle_lt(queryable, field, search_term) do
    queryable
    |> where([..., b], field(b, ^field) < ^search_term)
  end

  @doc """
  Builds a searched `queryable` on top of the given `queryable` using `field` and `search_type`
  when the `search_term` is `gteq`.

  ## Examples

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_gteq(queryable, :field_1, "field_!")
      #Ecto.Query<from p in "parents", where: p.field_1 >= ^"field_!">
  """
  @spec handle_gteq(Ecto.Query.t(), atom, term) :: {Ecto.Query.t()}
  def handle_gteq(queryable, field, search_term) do
    queryable
    |> where([..., b], field(b, ^field) >= ^search_term)
  end

  @doc """
  Builds a searched `queryable` on top of the given `queryable` using `field` and `search_type`
  when the `search_term` is `lteq`.

  ## Examples

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_lteq(queryable, :field_1, "field_!")
      #Ecto.Query<from p in "parents", where: p.field_1 <= ^"field_!">
  """
  @spec handle_lteq(Ecto.Query.t(), atom, term) :: {Ecto.Query.t()}
  def handle_lteq(queryable, field, search_term) do
    queryable
    |> where([..., b], field(b, ^field) <= ^search_term)
  end

  @doc """
  Builds a searched `queryable` on top of the given `queryable` using `field` and `search_type`
  when the `search_term` is `is_nil`.

  ## Examples

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_is_nil(queryable, :field_1, "false")
      #Ecto.Query<from p in "parents", where: not is_nil(p.field_1)>
  """
  @spec handle_is_nil(Ecto.Query.t(), atom, term) :: {Ecto.Query.t()}
  def handle_is_nil(queryable, field, "false") do
    queryable
    |> where([..., b], not is_nil(field(b, ^field)))
  end

  def handle_is_nil(queryable, field, _) do
    queryable
    |> where([..., b], is_nil(field(b, ^field)))
  end

  @doc """
  Builds a searched `queryable` on top of the given `queryable` using `field` and `search_type`
  when the `search_term` is `in`.

  ## Examples

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_in(queryable, :field_1, ["1", "2"])
      #Ecto.Query<from p in "parents", where: p.field_1 in ^["1", "2"]>
  """
  @spec handle_in(Ecto.Query.t(), atom, term) :: {Ecto.Query.t()}
  def handle_in(queryable, field, search_term) do
    queryable
    |> where([..., b], field(b, ^field) in ^search_term)
  end

  @doc """
  Builds a searched `queryable` on top of the given `queryable` using `field` and `search_type`
  when the `search_term` is `nin`.

  ## Examples

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_nin(queryable, :field_1, ["1", "2"])
      #Ecto.Query<from p in "parents", where: p.field_1 not in ^["1", "2"]>
  """
  @spec handle_nin(Ecto.Query.t(), atom, term) :: {Ecto.Query.t()}
  def handle_nin(queryable, field, search_term) do
    queryable
    |> where([..., b], field(b, ^field) not in ^search_term)
  end

  @doc """
  Builds a searched `queryable` on top of the given `queryable` using `field` and `search_type`
  when the `search_term` is `between`.

  ## Examples

      iex> alias Rummage.Ecto.Services.BuildSearchQuery
      iex> import Ecto.Query
      iex> queryable = from u in "parents"
      #Ecto.Query<from p in "parents">
      iex> BuildSearchQuery.handle_between(queryable, :field_1, ["1", "2"])
      #Ecto.Query<from p in "parents", where: p.field_1 >= ^"1", where: p.field_1 <= ^"2">
  """
  @spec handle_between(Ecto.Query.t(), atom, term) :: {Ecto.Query.t()}
  def handle_between(queryable, field, search_term) do
    [first, last] = search_term
    queryable
    |> where([..., b], field(b, ^field) >= ^first)
    |> where([..., b], field(b, ^field) <= ^last)
  end
end
