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

  @callback run(Ecto.Query.t(), map()) :: Ecto.Query.t()
  @callback format_params(Ecto.Query.t(), map(), keyword()) :: map()

  @doc """
  TODO: Improve Docs
  """
  defmacro __using__(_opts) do
    quote do
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
end
