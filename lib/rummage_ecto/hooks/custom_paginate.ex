defmodule Rummage.Ecto.Hook.CustomPaginate do
  @moduledoc """
  """

  use Rummage.Ecto.Hook

  use Rummage.Ecto.Hook

  @spec run(Ecto.Query.t(), map()) :: Ecto.Query.t()
  def run(q, s), do: handle_paginate(q, s)

  # Helper function which handles addition of paginated query on top of
  # the sent queryable variable
  defp handle_paginate(queryable, {field, page}) do
    module = get_module(queryable)
    name = :"__rummage_custom_paginate_#{field}"

    case function_exported?(module, name, 1) do
      true -> apply(module, name, [{queryable, page}])
      _ -> "No scope `#{field}` of type custom_paginate defined in #{module}"
    end
  end

  defp handle_paginate(queryable, paginate_params) do
    Rummage.Ecto.Hook.Paginate.run(queryable, paginate_params)
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
  def format_params(queryable, {paginate_scope, page}, opts) do
    module = get_module(queryable)
    name = :"__rummage_paginate_#{paginate_scope}"

    case function_exported?(module, name, 1) do
      true -> paginate_params = apply(module, name, [page])
        format_params(queryable, paginate_params, opts)
      _ ->
        case function_exported?(module, :"__rummage_custom_paginate_#{paginate_scope}", 1) do
          true -> {paginate_scope, page}
          _ -> raise "No scope `#{paginate_scope}` of type custom_paginate defined in the #{module}"
        end
    end
  end
  def format_params(queryable, paginate_params, opts) do
    Rummage.Ecto.Hook.Paginate.format_params(queryable, paginate_params, opts)
  end
end
