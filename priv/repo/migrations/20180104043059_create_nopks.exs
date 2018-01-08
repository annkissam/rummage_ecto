defmodule Rummage.Ecto.Repo.Migrations.CreateNopks do
  use Ecto.Migration

  def change do
    create table(:nopks, primary_key: false) do
      add :field, :float

      timestamps()
    end
  end
end
