defmodule Rummage.Schema.Sort do
  @moduledoc """

  Usage:

  ```elixir
  defmodule MyApp.Rummage.MyModel.Sort do
    use Rummage.Schema.Sort,
      default_name: "inserted_at",
      handlers: [
        category_name: %{field: :name, assoc: [inner: :category], ci: true},
        name: %{ci: true},
        price: %{},
      ]

    # Custom handlers...
    def sort(query, "inserted_at", order) do
      order = String.to_atom(order)

      from p in query,
        order_by: [
          {^order, p.inserted_at},
          {^order, p.id}
        ]
    end

    # Because we're overriding sort we need to call super...
    def sort(query, name, order) do
      super(query, name, order)
    end
  end
  ```
  """

  defmacro __using__(opts) do
    handlers = Keyword.get(opts, :handlers, [])
    default_name = Keyword.get(opts, :default_name, nil)
    default_order = Keyword.get(opts, :default_order, "asc")

    quote location: :keep do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query, warn: false

      @primary_key false
      embedded_schema do
        field :name, :string
        field :order, :string
      end

      def changeset(sort, attrs \\ %{}) do
        sort
        |> cast(attrs, [:name, :order])
        |> default_sort()
      end

      defp default_sort(changeset) do
        name = get_field(changeset, :name)

        if name && name != "" do
          changeset
        else
          changeset
          |> put_change(:name, unquote(default_name))
          |> put_change(:order, unquote(default_order))
        end
      end

      def rummage(query, sort) do
        if sort.name do
          sort(query, sort.name, sort.order)
        else
          query
        end
      end

      def sort(query, name, order) do
        handler = Keyword.get(unquote(handlers), String.to_atom(name))

        if handler do
          params = handler
          |> Map.put_new(:field, String.to_atom(name))
          |> Map.put_new(:assoc, [])
          |> Map.put(:order, String.to_atom(order))
          Rummage.Ecto.Hooks.Sort.run(query, params)
        else
          raise "Unknown Sort: #{name}"
        end
      end

      defoverridable [sort: 3]
    end
  end
end
