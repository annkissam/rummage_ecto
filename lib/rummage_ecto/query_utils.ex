defmodule Rummage.Ecto.QueryUtils do
  def schema_from_query(module) when is_atom(module), do: module
  def schema_from_query({_, module}) when is_atom(module), do: module
  def schema_from_query(%Ecto.Query{from: _from} = query), do: schema_from_query(query.from)
  def schema_from_query(%Ecto.SubQuery{query: query}), do: schema_from_query(query)
  def schema_from_query(%Ecto.Query.FromExpr{source: source}), do: schema_from_query(source)

  def schema_from_query(other),
    do: raise(ArgumentError, message: "argument error #{inspect(other)}")
end
