defmodule Rummage.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string
      add :description, :text
      add :parent_category_id, references(:categories)

      timestamps()
    end

    create unique_index(:categories, [:name])
    create index(:categories, [:parent_category_id])
  end
end
