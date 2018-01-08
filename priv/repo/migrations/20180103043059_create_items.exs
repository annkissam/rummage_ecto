defmodule Rummage.Ecto.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add :item_id, :id, primary_key: true
      add :item_price, :float
      add :category_id, references(:categories)

      timestamps()
    end
  end
end
