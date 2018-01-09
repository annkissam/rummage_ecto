defmodule Rummage.Ecto.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :price, :float
      add :available, :boolean
      add :category_id, references(:categories)

      timestamps()
    end
  end
end
