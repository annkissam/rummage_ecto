defmodule Rummage.Ecto.Services.BuildSearchQueryTest do
  use ExUnit.Case
  alias Rummage.Ecto.Services.BuildSearchQuery
  doctest BuildSearchQuery

  @supported_fragments_one ["date_part('day', ?)",
                            "date_part('month', ?)",
                            "date_part('year', ?)",
                            "date_part('hour', ?)",
                            "lower(?)",
                            "upper(?)"]

  @supported_fragments_two ["concat(?, ?)",
                            "coalesce(?, ?)"]

  @search_types ~w{like ilike eq gt lt gteq lteq in}a
  @search_exprs ~w{where or_where not_where}a

  test "Definitions of Single Interpolation Fragments" do
    for fragment <- @supported_fragments_one do
      for search_type <- @search_types do
        for search_expr <- @search_exprs do
          name = :"handle_#{search_type}"
          queryable = Rummage.Ecto.Product
          term = "abcd"
          result = apply(BuildSearchQuery, name,
                [queryable, {:fragment, fragment, :field}, term, search_expr])

          assert result == apply(BuildSearchQuery, name,
                [queryable, {:fragment, fragment, :field}, term, search_expr])
        end
      end

      search_type = :in
      for search_expr <- @search_exprs do
        name = :"handle_#{search_type}"
        queryable = Rummage.Ecto.Product
        term = true
        result = apply(BuildSearchQuery, name,
              [queryable, {:fragment, fragment, :field}, term, search_expr])

        assert result == apply(BuildSearchQuery, name,
              [queryable, {:fragment, fragment, :field}, term, search_expr])
      end

      for search_expr <- @search_exprs do
        name = :"handle_#{search_type}"
        queryable = Rummage.Ecto.Product
        term = false
        result = apply(BuildSearchQuery, name,
              [queryable, {:fragment, fragment, :field}, term, search_expr])

        assert result == apply(BuildSearchQuery, name,
              [queryable, {:fragment, fragment, :field}, term, search_expr])

      end

      search_type = :is_nil
      for search_expr <- @search_exprs do
        name = :"handle_#{search_type}"
        queryable = Rummage.Ecto.Product
        term = true
        result = apply(BuildSearchQuery, name,
              [queryable, {:fragment, fragment, :field}, term, search_expr])

        assert result == apply(BuildSearchQuery, name,
              [queryable, {:fragment, fragment, :field}, term, search_expr])
      end

      for search_expr <- @search_exprs do
        name = :"handle_#{search_type}"
        queryable = Rummage.Ecto.Product
        term = false
        result = apply(BuildSearchQuery, name,
              [queryable, {:fragment, fragment, :field}, term, search_expr])

        assert result == apply(BuildSearchQuery, name,
              [queryable, {:fragment, fragment, :field}, term, search_expr])
      end
    end
  end

  test "Definitions of Double Interpolation Fragments" do
    for fragment <- @supported_fragments_two do
      for search_type <- @search_types do
        for search_expr <- @search_exprs do
          name = :"handle_#{search_type}"
          queryable = Rummage.Ecto.Product
          term = "abcd"
          result = apply(BuildSearchQuery, name,
                [queryable, {:fragment, fragment, :field1, :field2}, term, search_expr])

          assert result == apply(BuildSearchQuery, name,
                [queryable, {:fragment, fragment, :field1, :field2}, term, search_expr])
        end
      end

      search_type = :in
      for search_expr <- @search_exprs do
        name = :"handle_#{search_type}"
        queryable = Rummage.Ecto.Product
        term = true
        result = apply(BuildSearchQuery, name,
              [queryable, {:fragment, fragment, :field1, :field2}, term, search_expr])

        assert result == apply(BuildSearchQuery, name,
              [queryable, {:fragment, fragment, :field1, :field2}, term, search_expr])
      end

      for search_expr <- @search_exprs do
        name = :"handle_#{search_type}"
        queryable = Rummage.Ecto.Product
        term = false
        result = apply(BuildSearchQuery, name,
              [queryable, {:fragment, fragment, :field1, :field2}, term, search_expr])

        assert result == apply(BuildSearchQuery, name,
              [queryable, {:fragment, fragment, :field1, :field2}, term, search_expr])
      end

      search_type = :is_nil
      for search_expr <- @search_exprs do
        name = :"handle_#{search_type}"
        queryable = Rummage.Ecto.Product
        term = true
        result = apply(BuildSearchQuery, name,
              [queryable, {:fragment, fragment, :field1, :field2}, term, search_expr])

        assert result == apply(BuildSearchQuery, name,
              [queryable, {:fragment, fragment, :field1, :field2}, term, search_expr])
      end

      for search_expr <- @search_exprs do
        name = :"handle_#{search_type}"
        queryable = Rummage.Ecto.Product
        term = false
        result = apply(BuildSearchQuery, name,
              [queryable, {:fragment, fragment, :field1, :field2}, term, search_expr])

        assert result == apply(BuildSearchQuery, name,
              [queryable, {:fragment, fragment, :field1, :field2}, term, search_expr])
      end
    end
  end
end
