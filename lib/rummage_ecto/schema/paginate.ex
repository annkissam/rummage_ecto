defmodule Rummage.Schema.Paginate do
  @moduledoc """

  Usage:

  ```elixir
  defmodule MyApp.Rummage.Paginate do
    use Rummage.Schema.Paginate
  end
  ```
  """

  defmacro __using__(opts) do
    per_page = Keyword.get(opts, :per_page, Rummage.Ecto.Config.per_page())
    repo = Keyword.get(opts, :repo, Rummage.Ecto.Config.repo())

    quote location: :keep do
      use Ecto.Schema
      import Ecto.Changeset

      @primary_key false
      embedded_schema do
        field :page, :integer, default: 1
        field :per_page, :integer
        field :max_page, :integer
        field :total_count, :integer
      end

      def changeset(paginate, attrs \\ %{}) do
        paginate
        |> cast(attrs, [:page, :per_page])
        |> set_default_per_page()
      end

      defp set_default_per_page(changeset) do
        per_page = get_field(changeset, :per_page)

        if per_page && per_page != "" do
          changeset
        else
          put_change(changeset, :per_page, unquote(per_page))
        end
      end

      defp rummage_changeset(paginate, attrs) do
        paginate
        |> cast(attrs, [:max_page, :total_count])
      end

      def rummage(query, nil), do: {query, nil}

      def rummage(query, paginate) do
        # Add total_count & max_page
        params = Rummage.Ecto.Hooks.Paginate.format_params(query, paginate, [repo: unquote(repo)])

        # per_page -1 == Show all results
        params = if paginate.per_page == -1 do
          Map.put(params, :max_page, 1)
        else
          params
        end

        # skip pagination if there's only one page
        query = if params.max_page == 1 do
          query
        else
          Rummage.Ecto.Hooks.Paginate.run(query, paginate)
        end

        paginate = rummage_changeset(paginate, params) |> apply_changes()

        {query, paginate}
      end
    end
  end
end
