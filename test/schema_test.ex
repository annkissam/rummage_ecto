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
  end

  test "TestSchema has inserted_at_year function defined" do
    assert Code.ensure_loaded?(TestSchema) == true
    assert function_exported?(TestSchema, :__rummage_field_inserted_at_year, 0) == true
    assert function_exported?(TestSchema, :__rummage_field_upper_case_name, 0) == true
  end
end
