defmodule Architect.Schema.Step do
  @moduledoc """
  Steps are the individual and executable subdivisions of tasks.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Architect.Schema.Run

  @status [:pending, :running, :completed, :failed]
  @type status() :: :pending | :running | :completed | :failed

  @type t() :: [
          id: binary(),
          run_id: binary(),
          run: Run.t() | Ecto.Association.NotLoaded.t(),
          step_id: binary(),
          status: status(),
          inputs: map(),
          outputs: map(),
          completed_at: DateTime.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        ]

  @required_attrs [
    :run_id,
    :step_id,
    :status
  ]

  @optional_attrs [
    :inputs,
    :outputs,
    :completed_at
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "steps" do
    belongs_to :run, Run
    field :step_id, :string
    field :status, Ecto.Enum, values: @status
    field :inputs, :map
    field :outputs, :map
    field :completed_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(task, attrs) do
    task
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> cast_assoc(:run, with: &Run.changeset/2, required: false)
    |> validate_required(@required_attrs)
    |> validate_inclusion(:status, @status)
    |> unique_constraint([:run_id, :step_id])
  end

  def run_step_query(run_id, step_id) do
    from s in __MODULE__,
      where: s.run_id == ^run_id and s.step_id == ^step_id,
      select: s
  end

  def run_steps_query(run_id) do
    from s in __MODULE__,
      where: s.run_id == ^run_id,
      select: s
  end
end
