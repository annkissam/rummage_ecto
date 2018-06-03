defmodule Rummage.Ecto.Schema do
  @moduledoc """
  This module is meant to be `use`d by a module (typically an `Ecto.Schema`).

  This isn't a required module for using `Rummage`, but it allows us to extend
  its functionality.
  """

  defmacro __using__(opts) do
    quote do
      use Ecto.Schema
      import Ecto.Query
      import unquote(__MODULE__)
    end
  end

  defmacro rummage_field(field, do: block) do
    quote do
      defmacro unquote(field)(), do: unquote(block)
    end
  end
end
