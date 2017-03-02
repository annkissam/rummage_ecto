defmodule Rummage.Ecto.Hook do
  @moduledoc """
  This module defines a behavior that `Rummage.Hooks` have to follow.
  Custom Search, Sort and Paginate hooks should follow this behavior
  as well.
  """
  @callback run(queryable :: Ecto.Query.t, rummage :: map) :: {queryable :: Ecto.Query.t, rummage :: map}
end
