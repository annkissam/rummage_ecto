defmodule Rummage.Ecto.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :category_name, :string
      add :category_id, references(:categories)

      timestamps
    end
  end
end
