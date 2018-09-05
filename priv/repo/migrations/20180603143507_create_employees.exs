defmodule Rummage.Repo.Migrations.CreateEmployees do
  use Ecto.Migration

  def change do
    create table(:employees, primary_key: false) do
      add :first_name, :string
      add :last_name, :string
      add :date_of_birth, :date

      timestamps()
    end
  end
end
