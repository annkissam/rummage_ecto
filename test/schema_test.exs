defmodule Rummage.Ecto.SchemaTest do
  use ExUnit.Case

  defmodule TestSchema do
    @moduledoc false

    use Rummage.Ecto.Schema

    schema "test_schema" do
      field :name, :string
      field :age, :integer

      timestamps()
    end

    rummage_field :inserted_at_year do
      {:fragment, "date_part('year', ?)", :inserted_at}
    end

    rummage_field :upper_case_name do
      {:fragment, "upper(?)", :name}
    end

    rummage_scope :small_page, [type: :custom_paginate], fn({query, page}) ->
      offset = 5 * (page - 1)

      query
      |> limit(5)
      |> offset(^offset)
    end
  end

  test "TestSchema has inserted_at_year function defined" do
    assert Code.ensure_loaded?(TestSchema) == true
    assert function_exported?(TestSchema, :__rummage_field_inserted_at_year, 0) == true
    assert function_exported?(TestSchema, :__rummage_field_upper_case_name, 0) == true
    assert function_exported?(TestSchema, :__rummage_custom_paginate_small_page, 1) == true
  end
end
