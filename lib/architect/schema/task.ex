defmodule Architect.Schema.Task do
  @moduledoc """
  Tasks store blueprints for creating runs.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  @type t() :: %__MODULE__{
          id: binary(),
          name: binary(),
          blueprint: map(),
          description: binary() | nil,
          enabled_at: DateTime.t() | nil,
          deleted_at: DateTime.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @type query_opts() :: [
          enabled: boolean() | nil,
          deleted: boolean() | nil
        ]

  @required_fields [:name, :blueprint]
  @optional_fields [:enabled_at, :deleted_at, :description]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tasks" do
    field :name, :string
    field :blueprint, :binary
    field :description, :binary
    field :enabled_at, :utc_datetime
    field :deleted_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def enabled_changeset(task, enabled),
    do: cast(task, %{enabled_at: if(enabled, do: DateTime.utc_now(), else: nil)}, [:enabled_at])

  def deleted_changeset(task, deleted),
    do: cast(task, %{deleted_at: if(deleted, do: DateTime.utc_now(), else: nil)}, [:deleted_at])

  def tasks_query(opts) do
    from(w in __MODULE__,
      select: w,
      order_by: [asc: w.name]
    )
    |> enabled_query(opts)
    |> deleted_query(opts)
  end

  def enabled_query(query, enabled: true) do
    from [w] in query,
      where: not is_nil(w.enabled_at)
  end

  def enabled_query(query, enabled: false) do
    from [w] in query,
      where: is_nil(w.enabled_at)
  end

  def enabled_query(query, _opts), do: query

  def deleted_query(query, deleted: true), do: query

  def deleted_query(query, _opts) do
    from [w] in query,
      where: is_nil(w.deleted_at)
  end
end
