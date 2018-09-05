defmodule Rummage.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :internal_code, :string, primary_key: true
      add :name, :string
      add :price, :float
      add :availability, :boolean
      add :description, :text
      add :category_id, references(:categories)

      timestamps()
    end

    create unique_index(:products, [:name])
    create index(:products, [:category_id])
    create index(:products, [:price])
    create index(:products, [:availability])
  end
end
