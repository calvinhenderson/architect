defmodule Architect.Schema.Run do
  @moduledoc """
  Runs are individual executions of tasks.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Architect.Schema.Task

  @trigger [:manual, :schedule, :webhook, :event]
  @type trigger() :: :manual | :schedule | :webhook | :event

  @status [:pending, :running, :suspended, :completed, :failed]
  @type status() :: :pending | :running | :suspended | :completed | :failed

  @type t() :: [
          id: binary(),
          context: map(),
          task_id: binary(),
          task: Task.t() | Ecto.Association.NotLoaded.t(),
          parent_id: binary(),
          parent: __MODULE__.t() | Ecto.Association.NotLoaded.t(),
          parent_step: binary() | nil,
          status: status(),
          metadata: map() | nil,
          inputs: map() | nil,
          outputs: map() | nil,
          trigger: trigger(),
          trigger_data: map() | nil,
          next_attempt_at: DateTime.t() | nil,
          attempts: non_neg_integer(),
          worker_id: binary() | nil,
          started_at: DateTime.t() | nil,
          completed_at: DateTime.t() | nil,
          last_heartbeat_at: DateTime.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        ]

  @required_attrs [
    :status,
    :task_id,
    :trigger,
    :attempts
  ]

  @optional_attrs [
    :context,
    :parent_id,
    :parent_step,
    :metadata,
    :inputs,
    :outputs,
    :trigger_data,
    :next_attempt_at,
    :worker_id,
    :started_at,
    :completed_at,
    :last_heartbeat_at
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "runs" do
    # The execution context map that is built during runtime
    field :context, :map, default: %{}, virtual: true

    belongs_to :task, Task

    belongs_to :parent, __MODULE__
    field :parent_step, :string

    field :status, Ecto.Enum, values: @status
    field :metadata, :map
    field :inputs, :map
    field :outputs, :map
    field :trigger, Ecto.Enum, values: @trigger
    field :trigger_data, :map
    field :next_attempt_at, :utc_datetime_usec
    field :attempts, :integer
    field :worker_id, :string
    field :started_at, :utc_datetime_usec
    field :completed_at, :utc_datetime_usec
    field :last_heartbeat_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(run, attrs) do
    run
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> validate_inclusion(:status, @status)
    |> validate_inclusion(:trigger, @trigger)
    |> validate_number(:attempts, greater_than_or_equal_to: 0)
    |> unique_constraint([:parent_id, :parent_step])
  end

  def task_runs_query(task_id) do
    from r in __MODULE__,
      where: r.task_id == ^task_id,
      limit: 10,
      select: r
  end

  def stale_runs_query(opts \\ []) do
    stale_after = Keyword.get(opts, :stale_after, 5)

    from r in __MODULE__,
      where: r.status == :running and r.last_heartbeat_at <= ago(^stale_after, "minute"),
      select: r
  end

  def claim_run_query(worker_id) do
    available_runs = available_runs_query()

    from r in __MODULE__,
      join: available in subquery(available_runs),
      on: r.id == available.id,
      update: [
        set: [
          status: :running,
          worker_id: ^worker_id,
          started_at: fragment("NOW()"),
          last_heartbeat_at: fragment("NOW()")
        ]
      ],
      select: r
  end

  defp available_runs_query do
    from r in __MODULE__,
      where: r.status == :pending,
      limit: 1,
      lock: "FOR UPDATE SKIP LOCKED",
      select: [:id]
  end
end
