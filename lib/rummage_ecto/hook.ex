defmodule RummageEcto.Hook do
  @callback run(query :: term, rummage :: term) :: {query :: term}
end
