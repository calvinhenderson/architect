defmodule Architect.Execution do
  @moduledoc """
  Provides an API for managing the state of running tasks.
  """
  alias Architect.Schema.Step
  alias Architect.Repo
  alias Architect.Schema.Run
  alias Architect.Schema.Task

  @doc """
  Adds a new run to the worker queue.
  """
  @spec enqueue_run(Task.t(), map(), keyword()) :: {:ok, Run.t()} | {:error, Ecto.Changeset.t()}
  def enqueue_run(%Task{} = task, %{} = inputs, opts \\ []) do
    params = %Run{
      task: task,
      parent: Keyword.get(opts, :parent),
      parent_step: Keyword.get(opts, :parent_step),
      status: :pending,
      metadata: Keyword.get(opts, :metadata),
      inputs: inputs,
      trigger: Keyword.get(opts, :trigger),
      trigger_data: Keyword.get(opts, :trigger_data),
      next_attempt_at: DateTime.utc_now(),
      attempts: 0
    }

    Run.changeset(%Run{}, params)
    |> Repo.insert()
  end

  @doc """
  Claims the next available run from the queue.

  ## Examples

      iex> claim_run("Node0:Worker0")
      {:ok, %Run{}}

      iex> claim_run("Node1:Worker1")
      :empty
  """
  @spec claim_run(uuid :: term()) :: {:ok, Run.t()} | :empty
  def claim_run(worker_id) do
    Run.claim_run_query(worker_id)
    |> Repo.update_all([])
    |> case do
      {1, [claimed_run]} ->
        {:ok, claimed_run}

      {0, []} ->
        :empty
    end
  end

  @doc """
  Refreshes the last heartbeat timestamp for a run.
  """
  @spec update_run_heartbeat(Run.t()) ::
          {:ok, Run.t()} | {:error, Ecto.Changeset.t()}
  def update_run_heartbeat(%Run{} = run) do
    run
    |> Run.changeset(%{last_heartbeat_at: DateTime.utc_now()})
    |> Repo.update()
  end

  @doc """
  Upserts the step for a given run.

  ## Examples

      iex> upsert_run_step(%Step{}, %{run_id: "valid-run", status: :pending})
      {:ok, %Step{id: "valid-step"}}

      iex> upsert_run_step(%Step{id: "valid-step"}, %{status: :completed})
      {:ok, %Step{}}
  """
  @spec upsert_run_step(Step.t(), map()) :: {:ok, Step.t()} | {:error, Ecto.Changeset.t()}
  def upsert_run_step(%Step{} = step, %{} = params) do
    step
    |> Step.changeset(params)
    |> Repo.insert(on_conflict: :replace_all)
  end

  @doc """
  Marks a run as completed.

  ## Examples

      iex> complete_run(%Run{}, :completed)
      {:ok, %Run{status: :completed, completed_at: ...}}

      iex> complete_run(%Run{}, :failed)
      {:ok, %Run{status: :failed, completed_at: ...}}
  """
  @spec complete_run(Run.t(), atom()) :: {:ok, Run.t()} | {:error, Ecto.Changeset.t()}
  def complete_run(run, status) do
    run
    |> Run.changeset(%{
      status: status,
      completed_at: DateTime.utc_now()
    })
    |> Repo.update()
  end

  @spec update_run(Run.t(), map()) :: {:ok, Run.t()} | {:error, Ecto.Changeset.t()}
  def update_run(run, params) do
    run
    |> Run.changeset(params)
    |> Repo.update()
  end

  @doc """
  Will free runs that have gone stale.

  ## Examples

      # Default stale interval of 5 minutes
      iex> reap_stale_runs()
      {:ok, [%Run{}, ...]}

      # Reset all runs
      iex> reap_stale_runs(stale_after: 0)
      {:ok, [%Run{}, ...]}
  """
  @spec reap_stale_runs(keyword()) :: {non_neg_integer(), nil | [Run.t()]}
  def reap_stale_runs(opts \\ []) do
    Run.stale_runs_query(opts)
    |> Repo.update_all(set: [status: "pending", worker_id: nil, last_heartbeat_at: nil])
  end
end
