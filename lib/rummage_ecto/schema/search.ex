defmodule Rummage.Schema.Search do
  @moduledoc """

  Usage:

  ```elixir
  defmodule MyApp.Rummage.MyModel.Search do
    use Rummage.Schema.Search,
      handlers: [
        category_name: %{search_field: :name, search_type: :ilike, assoc: [inner: :category]},
        price_gteq: %{search_field: :price, search_type: :gteq},
        price_lteq: %{search_field: :price, search_type: :lteq},
        name: %{search_type: :ilike},
        month: :integer,
        year: :integer,
      ]

    # Skip blank searches
    def search(query, name, nil), do: query
    def search(query, name, ""), do: query

    def search(query, :month, month) do
      from p in query,
        where: fragment("date_part('month', ?)", p.inserted_at) == ^month
    end

    def search(query, :year, year) do
      from p in query,
        where: fragment("date_part('year', ?)", p.inserted_at) == ^year
    end

    # Because we're overriding search we need to call super...
    def search(query, name, value) do
      super(query, name, value)
    end
  end
  ```
  """

  defmacro __using__(opts) do
    handlers = Keyword.get(opts, :handlers, [])
    changeset_fields = Keyword.keys(handlers)
    schema_fields = Enum.map(handlers, fn({name, handler}) ->
      if is_atom(handler) do
        quote do field unquote(name), unquote(handler) end
      else
        quote do
          type = Map.get(unquote(handler), :type, :string)
          field unquote(name), type
        end
      end
    end)

    # TODO: Is this better?
    # search_functions = Enum.map(handlers, fn{name, handler} ->
    #   quote do
    #     def search(query, unquote(name), value) do
    #       params = unquote(handler)
    #       |> Map.put_new(:assoc, [])
    #       |> Map.put_new(:search_field, unquote(name))
    #       |> Map.put(:search_term, value)
    #       |> Map.put_new(:search_expr, :where)

    #       Rummage.Ecto.Hooks.Search.run(query, %{Atom.to_string(unquote(name)) => params})
    #     end
    #   end
    # end)

    quote location: :keep do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query, warn: false

      @primary_key false
      embedded_schema do
        unquote(schema_fields)
      end

      def changeset(sort, attrs \\ %{}) do
        sort
        |> cast(attrs, unquote(changeset_fields))
      end

      def rummage(query, nil), do: query

      def rummage(query, search) do
        fields = unquote(changeset_fields)

        Enum.reduce(fields, query, fn(field, q) ->
          search(q, field, Map.get(search, field))
        end)
      end

      def search(query, _name, nil), do: query
      def search(query, _name, ""), do: query

      # unquote(search_functions)

      def search(query, name, value) do
        handler = Keyword.get(unquote(handlers), name)

        if handler && is_map(handler) do
          params = handler
          |> Map.drop([:type])
          |> Map.put_new(:assoc, [])
          |> Map.put_new(:search_field, name)
          |> Map.put(:search_term, value)
          |> Map.put_new(:search_expr, :where)

          Rummage.Ecto.Hooks.Search.run(query, %{Atom.to_string(name) => params})
        else
          raise "Unknown Search: #{name}"
        end
      end

      defoverridable [search: 3]
    end
  end
end
