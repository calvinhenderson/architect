defmodule Architect.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string, null: false
      add :blueprint, :map, null: false
      add :description, :binary
      add :metadata, :map

      add :enabled_at, :utc_datetime
      add :deleted_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
