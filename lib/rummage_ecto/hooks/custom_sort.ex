defmodule Rummage.Ecto.Hook.CustomSort do
  @moduledoc """
  """

  use Rummage.Ecto.Hook

  @spec run(Ecto.Query.t(), map()) :: Ecto.Query.t()
  def run(q, s), do: handle_sort(q, s)

  # Helper function which handles addition of paginated query on top of
  # the sent queryable variable
  defp handle_sort(queryable, {field, order}) do
    module = get_module(queryable)
    name = :"__rummage_custom_sort_#{field}"

    case function_exported?(module, name, 1) do
      true -> apply(module, name, [{queryable, order}])
      _ -> "No scope `#{field}` of type custom_sort defined in #{module}"
    end
  end

  defp handle_sort(queryable, sort_params) do
    Rummage.Ecto.Hook.Sort.run(queryable, sort_params)
  end

  @doc """
  Callback implementation for `Rummage.Ecto.Hook.format_params/2`.

  This function ensures that params for each field have keys `assoc`, `order1
  which are essential for running this hook module.

  ## Examples
      iex> alias Rummage.Ecto.Hook.CustomSort
      iex> Sort.format_params(Parent, %{}, [])
      %{assoc: [], order: :asc}
  """
  @spec format_params(Ecto.Query.t(), map() | tuple(), keyword()) :: map()
  def format_params(queryable, {sort_scope, order}, opts) do
    module = get_module(queryable)
    name = :"__rummage_sort_#{sort_scope}"

    case function_exported?(module, name, 1) do
      true -> sort_params = apply(module, name, [order])
        format_params(queryable, sort_params, opts)
      _ ->
        case function_exported?(module, :"__rummage_custom_sort_#{sort_scope}", 1) do
          true -> {sort_scope, order}
          _ -> raise "No scope `#{sort_scope}` of type custom_sort defined in the #{module}"
        end
    end
  end

  def format_params(_queryable, sort_params, _opts) do
    sort_params
    |> Map.put_new(:assoc, [])
    |> Map.put_new(:order, :asc)
  end
end
