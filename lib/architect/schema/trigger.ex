defmodule Architect.Schema.Trigger do
  @moduledoc """
  A trigger is a conditional listener that may execute a run.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Architect.Schema.Task

  @trigger_types [:webhook, :schedule, :event]
  @type trigger_type() :: :webhook | :schedule | :event

  @type t() :: [
          id: binary(),
          name: binary(),
          type: trigger_type(),
          if_expr: binary() | nil,
          webhook_path: binary() | nil,
          event: binary() | nil,
          cron_expression: binary() | nil,
          next_run_at: DateTime.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        ]

  @required_fields [
    :name,
    :type
  ]

  @optional_fields [
    :if_expr,
    :webhook_path,
    :event,
    :cron_expression,
    :next_run_at
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "triggers" do
    belongs_to :task, Task
    field :name, :string
    field :type, :string
    field :if_expr, :string

    # Webhook properties
    field :webhook_path, :string

    # Event properties
    field :event, :string

    # Schedule properties
    field :cron_expression, :string
    field :next_run_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  def changeset(trigger, attrs) do
    trigger
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, @trigger_types)
    |> unique_constraint([:task_id, :name])
  end

  def active_triggers_query do
    active_tasks = Task.tasks_query(enabled: true, deleted: false)

    from t in __MODULE__,
      join: k in subquery(active_tasks),
      on: k.id == t.task_id,
      select: t
  end

  def triggers_type_query(type) do
    active_triggers = active_triggers_query()

    from t in subquery(active_triggers),
      where: t.type == ^type,
      select: t
  end
end
