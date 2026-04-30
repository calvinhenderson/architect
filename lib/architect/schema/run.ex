defmodule Architect.Schema.Run do
  @moduledoc """
  Runs are individual executions of tasks.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Architect.Schema.Task

  @status [:pending, :running, :scheduled, :completed, :failed]
  @type status() :: :pending | :running | :scheduled | :completed | :failed

  @type t() :: [
          id: binary(),
          task_id: binary(),
          task: Task.t() | Ecto.Association.NotLoaded.t(),
          status: status(),
          metadata: map(),
          context: map(),
          run_after: DateTime.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        ]

  @required_attrs []

  @optional_attrs [
    :metadata,
    :context
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "runs" do
    field :status, Ecto.Enum, values: @status
    field :metadata, :map, default: %{}
    field :context, :map, default: %{}, virtual: true
    field :runs_after, :utc_datetime_usec, default: DateTime.utc_now()

    belongs_to :task, Task

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(run, attrs) do
    run
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> cast_assoc(:task, with: &Task.changeset/2)
    |> validate_required(@required_attrs)
    |> validate_inclusion(:status, @status)
  end
end
