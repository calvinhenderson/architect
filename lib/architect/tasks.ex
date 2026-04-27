defmodule Architect.Tasks do
  @moduledoc """
  An API for interacting with Tasks.
  """

  alias Architect.Schema.Task
  alias Architect.Repo

  ## Tasks

  @doc """
  Lists tasks.
  """
  @spec list_tasks(Task.query_opts()) :: [Task.t()]
  def list_tasks(opts \\ []) do
    Task.tasks_query(opts)
    |> Repo.all()
  end

  @doc """
  Gets a single task. Raises if one is not found.
  """
  @spec get_task!(binary()) :: Task.t() | no_return()
  def get_task!(task_id), do: Repo.get!(Task, task_id)

  @doc """
  Gets a single task.
  """
  @spec get_task(binary()) :: Task.t() | nil
  def get_task(task_id), do: Repo.get(Task, task_id)

  @doc """
  Returns a changeset for creating a task.
  """
  @spec create_changeset(Task.t(), map()) :: Ecto.Changeset.t()
  def create_changeset(%Task{} = task, params),
    do: Task.changeset(task, params)

  @doc """
  Creates a task.
  """
  @spec create_task(Task.t(), map()) :: {:ok, Task.t()} | {:error, Ecto.Changeset.t()}
  def create_task(%Task{} = task, params) do
    task
    |> Task.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Returns a changeset for updating a task.
  """
  @spec update_changeset(Task.t(), map()) :: Ecto.Changeset.t()
  def update_changeset(task, params),
    do: Task.changeset(task, params)

  @doc """
  Updates a task.
  """
  @spec update_task(Task.t(), map()) :: {:ok, Task.t()} | {:error, Ecto.Changeset.t()}
  def update_task(task, params) do
    task
    |> Task.changeset(params)
    |> Repo.update()
  end

  @doc """
  Enables a task.
  """
  @spec enable_task(Task.t()) ::
          {:ok, Task.t()} | {:error, Ecto.Changeset.t()}
  def enable_task(task) do
    task
    |> Task.enabled_changeset(true)
    |> Repo.update()
  end

  @doc """
  Disables a task.
  """
  @spec disable_task(Task.t()) ::
          {:ok, Task.t()} | {:error, Ecto.Changeset.t()}
  def disable_task(task) do
    task
    |> Task.enabled_changeset(false)
    |> Repo.update()
  end

  @doc """
  Deletes a task.
  """
  @spec delete_task(Task.t()) :: {:ok, Task.t()} | {:error, Ecto.Changeset.t()}
  def delete_task(task) do
    task
    |> Task.deleted_changeset(true)
    |> Repo.update()
  end
end
