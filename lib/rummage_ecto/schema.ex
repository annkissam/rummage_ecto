defmodule Rummage.Ecto.Schema do
  @moduledoc """
  This module is meant to be `use`d by a module (typically an `Ecto.Schema`).

  This isn't a required module for using `Rummage`, but it allows us to extend
  its functionality.
  """

  @rummage_scope_types ~w{search sort paginate custom_search custom_sort custom_paginate}a

  @doc """
  This macro allows us to leverage features in `Rummage.Ecto.Schema`. It takes
  advantage of `Ecto`, `rummage_field` and `rummage_scope`

  ## Usage:

  ```elixir
  defmodule MySchema do
    use Rummage.Ecto.Schema

    schema "my_table" do
      field :field1, :integer
      field :field2, :integer

      timestamps()
    end

    rummage_field :field1_or_field2 do
      {:fragment, "coalesce(?, ?)", :name, :description}
    end

    rummage_scope :show_page, [type: :paginate], fn(page) ->
      %{per_page: 10, page: page}
    end
  end
  ```
  """
  defmacro __using__(opts) do
    quote do
      use Ecto.Schema
      use Rummage.Ecto, unquote(opts)
      import Ecto.Query
      import unquote(__MODULE__)
    end
  end

  @doc """
  Rummage Field is a way to define a field which can be used to search, sort,
  paginate through. This field might not exist in the database or the schema,
  but can be represented as a `fragments` query using multiple fields.

  NOTE: Currently this feature has some limitations due to limitations put on
  Ecto's fragments. Ecto 3.0 is expected to come out with `unsafe_fragment`,
  which will give this feature great flexibility. This feature is also quite
  dependent on what database engine is being used. For now, we have made
  a few fragments available (the list can be seen [here]()) which are thoroughly
  tested on postgres. If these fragments don't do it, you can use `rummage_scope`
  to accomplish a similar functionality.

  ## Usage:

  To use upper case name as rummage field:

  ```elixir
  rummage_field :upper_case_name do
    {:fragment, "upper(?)", :name}
  end
  ```

  To use the hour for created_at as rummage field:
  rummage_field :created_at_hour do
    {:fragment, "date_part('hour', ?)", :inserted_at}
  end
  """
  defmacro rummage_field(field, do: block) do
    name = :"__rummage_field_#{field}"

    quote do
      def unquote(name)(), do: unquote(block)
    end
  end

  defmacro rummage_scope(scope, [type: type], fun) when type in @rummage_scope_types do
    name = :"__rummage_#{type}_#{scope}"

    quote do
      def unquote(name)(term), do: unquote(fun).(term)
    end
  end
end
