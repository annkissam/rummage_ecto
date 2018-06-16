defmodule Rummage.Ecto.Hook.CustomSearch do
  @moduledoc """
  """

  use Rummage.Ecto.Hook

  @spec run(Ecto.Query.t(), map()) :: Ecto.Query.t()
  def run(q, s), do: handle_search(q, s)

  defp handle_search(queryable, search_params) do
    search_params
    |> Map.to_list()
    |> Enum.reduce(queryable, &search_queryable(&2, &1))
  end

  defp search_queryable(queryable, {search_name, search_term}) do
    module = get_module(queryable)
    name = :"__rummage_custom_search_#{search_name}"

    case function_exported?(module, name, 1) do
      true -> apply(module, name, [{queryable, search_term}])
      _ -> Rummage.Ecto.Hook.Search.run(queryable, %{search_name => search_term})
    end
  end

  @doc """
  Callback implementation for `Rummage.Ecto.Hook.format_params/2`.

  This function ensures that params for each field have keys `assoc`, `search_type` and
  `search_expr` which are essential for running this hook module.

  ## Examples
      iex> alias Rummage.Ecto.Hook.CustomSearch
      iex> Search.format_params(Parent, %{field: %{}}, [])
      %{field: %{assoc: [], search_expr: :where, search_type: :eq}}
  """
  @spec format_params(Ecto.Query.t(), map(), keyword()) :: map()
  def format_params(queryable, search_params, _opts) do
    search_params
    |> Map.to_list()
    |> Enum.map(&put_keys(&1, queryable))
    |> Enum.into(%{})
  end

  defp put_keys({field, %{} = field_params}, _queryable) do
    field_params = field_params
      |> Map.put_new(:assoc, [])
      |> Map.put_new(:search_type, :eq)
      |> Map.put_new(:search_expr, :where)

    {field, field_params}
  end

  defp put_keys({search_scope, field_value}, queryable) do
    module = get_module(queryable)
    name = :"__rummage_search_#{search_scope}"
    case function_exported?(module, name, 1) do
      true -> {field, search_params} = apply(module, name, [field_value])
        put_keys({field, search_params}, queryable)
      _ ->
        case function_exported?(module, :"__rummage_custom_search_#{search_scope}", 1) do
          true -> {search_scope, field_value}
          _ -> raise "No scope `#{search_scope}` of type custom_search defined in the #{module}"
        end
    end
  end
end
