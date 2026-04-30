defmodule Architect.Schema.Step do
  @moduledoc """
  Steps are the individual and executable subdivisions of tasks.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Architect.Schema.Run

  @status [:pending, :running, :completed, :failed]
  @type status() :: :pending | :running | :completed | :failed

  @type t() :: [
          id: binary(),
          step_id: binary(),
          index: non_neg_integer(),
          status: status(),
          raw_inputs: map() | nil,
          outputs: map() | nil,
          if_expr: binary() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        ]

  @required_attrs [
    :step_id,
    :index,
    :status
  ]

  @optional_attrs [
    :raw_inputs,
    :outputs,
    :if_expr
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "steps" do
    field :step_id, :binary

    field :raw_inputs, :map, default: %{}
    field :outputs, :map, default: %{}

    field :if_expr, :string
    field :index, :integer
    field :status, Ecto.Enum, values: @status

    belongs_to :run, Run

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(task, attrs) do
    task
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> cast_assoc(:run, with: &Run.changeset/2)
    |> validate_required(@required_attrs)
    |> validate_number(:index, greater_than: 0)
    |> validate_inclusion(:status, @status)
  end
end
