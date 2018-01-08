defmodule Rummage.Ecto.Repo.Migrations.CreateComputers do
  use Ecto.Migration

  def change do
    create table(:computers, primary_key: false) do
      add :name, :string, primary_key: true
      add :price, :float

      timestamps()
    end
  end
end
