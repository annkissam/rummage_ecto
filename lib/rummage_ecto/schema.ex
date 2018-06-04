defmodule Rummage.Ecto.Schema do
  @moduledoc """
  This module is meant to be `use`d by a module (typically an `Ecto.Schema`).

  This isn't a required module for using `Rummage`, but it allows us to extend
  its functionality.
  """

  defmacro __using__(opts) do
    quote do
      use Ecto.Schema
      use Rummage.Ecto, unquote(opts)
      import Ecto.Query
      import unquote(__MODULE__)
    end
  end

  defmacro rummage_field(field, do: block) do
    name = :"field_#{field}"

    quote do
      def unquote(name)(), do: unquote(block)
    end
  end

  defmacro rummage_scope(scope, [type: type], fun) when type in ~w{search sort paginate}a do
    name = :"#{type}_#{scope}"

    quote do
      def unquote(name)(term), do: unquote(fun).(term)
    end
  end
end
