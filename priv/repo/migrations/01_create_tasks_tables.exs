defmodule Architect.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string, null: false
      add :blueprint, :map, null: false
      add :description, :string

      add :enabled_at, :utc_datetime
      add :deleted_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:tasks, [:name])

    create table(:runs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :task_id, references(:tasks, type: :binary_id, on_delete: :delete_all), null: false
      add :parent_id, references(:tasks, type: :binary_id, on_delete: :delete_all)
      add :parent_step, :string
      add :status, :string, null: false
      add :metadata, :map
      add :inputs, :map
      add :outputs, :map
      add :trigger, :string
      add :trigger_data, :map
      add :next_attempt_at, :utc_datetime_usec
      add :attempts, :integer, null: false
      add :worker_id, :string
      add :started_at, :utc_datetime_usec
      add :completed_at, :utc_datetime_usec
      add :last_heartbeat_at, :utc_datetime_usec
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:runs, [:parent_id, :parent_step], where: "parent_id IS NOT NULL")
    create index(:runs, [:status])

    create table(:steps, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :run_id, references(:runs, type: :binary_id, on_delete: :delete_all), null: false
      add :step_id, :string, null: false
      add :status, :string, null: false
      add :inputs, :map
      add :outputs, :map

      add :completed_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:steps, [:run_id, :step_id])
    create index(:steps, [:run_id, :status])
    create index(:steps, [:run_id])

    create table(:triggers, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :task_id, references(:tasks, type: :binary_id), null: false
      add :name, :string, null: false
      add :type, :string, null: false
      add :if_expr, :string

      add :webhook_path, :string
      add :event, :string
      add :cron_expression, :string
      add :next_run_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:triggers, [:task_id, :name])
    create index(:triggers, [:task_id])
    create index(:triggers, [:type])
  end
end
