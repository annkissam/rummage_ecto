defmodule Rummage.Ecto.Hook do
  @moduledoc """
  This module defines a behaviour that `Rummage.Ecto.Hook`s have to follow.

  This module also defines a `__using__` macro which mandates certain
  behaviours for a `Hook` module to follow.

  Native hooks that come with `Rummage.Ecto` follow this behaviour.

  Custom Search, Sort and Paginate hooks should follow this behaviour
  as well, in order for them to work well with `Rummage.Ecto`

  ## Usage

  - This is the preferred way of creating a Custom Hook. Using
  `Rummage.Ecto.Hook.__using__/1` macro, it can be ensured that `run/2` and
  `format_params/2` functions have been implemented.

  ```elixir
  defmodule MyCustomHook do
    use Rummage.Ecto.Hook

    def run(queryable, params), do: queryable

    def format_params(querable, params, opts), do: params
  end
  ```

  - A Custom Hook can also be created by using `Rummage.Ecto.Hook` `@behviour`

  ```elixir
  defmodule MyCustomHook do
    @behviour Rummage.Ecto.Hook

    def run(queryable, params), do: queryable

    def format_params(querable, params, opts), do: params
  end
  ```

  """

  @doc """
  All callback invoked by `Rummage.Ecto` which applies a set of translations
  to an ecto query, based on operations defined in the hook.
  """
  @callback run(Ecto.Query.t(), map()) :: Ecto.Query.t()

  @doc """
  All callback invoked by `Rummage.Ecto` which applies a set of translations
  to params passed to the hook. This is responsible for making sure that
  the params passed to the hook's `run/2` function are santized.
  """
  @callback format_params(Ecto.Query.t(), map(), keyword()) :: map()

  @doc """
  This macro allows us to write rummage hooks in an easier way. This includes
  a `@behaviour` module attribute and defines `raisable` callback implementations
  for the hook `using` this module. It also makes `run/2` and `format_params/3`
  overridable and expects them to be defined in the hook.

  ## Usage:

  ```elixir
  defmodule MyHook do
    use Rummage.Ecto.Hook

    def run(queryable, params), do: "do something"

    def format_params(q, params, opts), do: "do something"
  end
  ```

  For a better example, check out `Rummage.Ecto.Hook.Paginate` or any other
  hooks defined in `Rummage.Ecto`
  """
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      @behviour unquote(__MODULE__)

      @spec run(Ecto.Query.t(), map()) :: Ecto.Query.t()
      def run(queryable, params) do
        raise "run/2 not implemented for hook: #{__MODULE__}"
      end

      @spec format_params(Ecto.Query.t(), map(), keyword()) :: map()
      def format_params(queryable, params, opts) do
        raise "format_params/2 not implemented for hook: #{__MODULE__}"
      end

      defoverridable [run: 2, format_params: 3]
    end
  end

  def resolve_field(field, queryable) do
    module = get_module(queryable)
    name = :"__rummage_field_#{field}"
    case function_exported?(module, name, 0) do
      true -> apply(module, name, [])
      _ -> field
    end
  end

  def get_module(module) when is_atom(module), do: module
  def get_module({_, module}) when is_atom(module), do: module
  def get_module(%Ecto.Query{from: _from} = query), do: get_module(query.from)
  def get_module(%Ecto.SubQuery{query: query}), do: get_module(query)
end
