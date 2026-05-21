defmodule Architect.Schema.Task do
  @moduledoc """
  Tasks store blueprints for creating runs.
  """
  alias Architect.Blueprints

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
    field :blueprint, :map
    field :description, :string
    field :enabled_at, :utc_datetime
    field :deleted_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_blueprint()
  end

  defp validate_blueprint(changeset) do
    with blueprint when not is_nil(blueprint) <- get_field(changeset, :blueprint),
         {:ok, evaluated_blueprint} <- Blueprints.evaluate_blueprint(blueprint) do
      put_change(changeset, :blueprint, evaluated_blueprint)
    else
      nil ->
        changeset

      {:error, _reason, errors} ->
        Enum.reduce(errors, changeset, &add_error(&2, :blueprint, &1))
    end
  end

  def enabled_changeset(task, enabled) do
    enabled_at = if enabled, do: DateTime.utc_now(), else: nil
    deleted_at = if enabled, do: nil, else: task.deleted_at

    cast(
      task,
      %{enabled_at: enabled_at, deleted_at: deleted_at},
      [:enabled_at, :deleted_at]
    )
  end

  def deleted_changeset(task, deleted) do
    enabled_at = if deleted, do: nil, else: task.enabled_at
    deleted_at = if deleted, do: DateTime.utc_now(), else: nil

    cast(
      task,
      %{enabled_at: enabled_at, deleted_at: deleted_at},
      [:enabled_at, :deleted_at]
    )
  end

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
