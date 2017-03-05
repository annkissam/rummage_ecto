defmodule Rummage.Ecto.Category do
  use Ecto.Schema
  use Rummage.Ecto, repo: Rummage.Ecto.Repo, per_page: 3

  schema "categories" do
    field :category_name, :string

    timestamps
  end
end
