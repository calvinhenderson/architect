defmodule Architect.ExecutionTest do
  use Architect.DataCase

  import Architect.Factory
  import Ecto.Query

  alias Architect.Execution
  alias Architect.Schema.{Step, Run}

  @invalid_uuid "00000000-0000-0000-0000-000000000000"

  describe "get_run!/1" do
    test "returns the specified run" do
      %{id: run_id} = insert!(:run)
      assert %Run{id: ^run_id} = Execution.get_run!(run_id)
    end

    test "raises Ecto.NoResultsError when missing" do
      assert_raise Ecto.NoResultsError, fn ->
        Execution.get_run!(@invalid_uuid)
      end
    end
  end

  describe "get_run/1" do
    test "returns the specified run" do
      %{id: run_id} = insert!(:run)
      assert %Run{id: ^run_id} = Execution.get_run(run_id)
    end

    test "returns nil when missing" do
      assert is_nil(Execution.get_run(@invalid_uuid))
    end
  end

  describe "list_runs/1" do
    test "returns runs" do
      %{id: run_id} = insert!(:run)

      assert [%Run{id: ^run_id}] = Execution.list_runs()
    end

    test "returns filtered runs"
  end

  describe "get_step!/1" do
    test "returns the specified step" do
      %{id: step_id} = insert!(:step)
      assert %Step{id: ^step_id} = Execution.get_step!(step_id)
    end

    test "raises Ecto.NoResultsError when missing" do
      assert_raise Ecto.NoResultsError, fn ->
        Execution.get_step!(@invalid_uuid)
      end
    end
  end

  describe "get_step/1" do
    test "returns the specified step" do
      %{id: step_id} = insert!(:step)
      assert %Step{id: ^step_id} = Execution.get_step(step_id)
    end

    test "returns nil when missing" do
      assert is_nil(Execution.get_step(@invalid_uuid))
    end
  end

  describe "get_run_step/2" do
    test "returns the specified run step" do
      %{id: step_id, run_id: run_id} = insert!(:step, step_id: "step-1")

      assert %Step{id: ^step_id} = Execution.get_run_step(run_id, "step-1")
    end
  end

  describe "list_run_steps/2" do
    test "returns steps for the given run" do
      %{id: step_id, run_id: run_id} = insert!(:step)

      assert [%Step{id: ^step_id}] = Execution.list_run_steps(run_id)
    end

    test "returns filtered steps for the given run"
  end

  describe "enqueue_run/3" do
    test "adds new run to the queue" do
      task = insert!(:task)
      assert {:ok, %Run{} = run} = Execution.enqueue_run(task, %{}, trigger: :manual)
      assert run.task_id == task.id
    end
  end

  describe "claim_run/1" do
    test "claims the next available run" do
      run = insert!(:run)

      assert {:ok, %Run{} = claimed_run} = Execution.claim_run("testing")
      assert run.id == claimed_run.id
    end

    test "claims runs on a fifo basis" do
      tasks = Enum.map(0..3, fn _ -> insert!(:task) end)
      runs = Enum.map(tasks, fn task -> insert!(:run, task_id: task.id) end)

      Enum.each(runs, fn %{id: run_id} ->
        assert {:ok, %Run{id: ^run_id}} = Execution.claim_run("testing")
      end)
    end

    test "updates status to running" do
      %Run{id: run_id} = insert!(:run, status: :pending)

      assert {:ok, %Run{id: ^run_id} = claimed_run} = Execution.claim_run("testing")
      assert claimed_run.status == :running
    end

    test "updates heartbeat" do
      run = insert!(:run)

      assert is_nil(run.last_heartbeat_at)
      assert {:ok, %Run{} = claimed_run} = Execution.claim_run("testing")
      assert %DateTime{} = claimed_run.last_heartbeat_at
    end
  end

  describe "update_run_heartbeat/1" do
    test "updates heartbeat" do
      heartbeat = DateTime.utc_now() |> DateTime.add(-1, :minute)
      run = insert!(:run, last_heartbeat_at: heartbeat)

      assert {:ok, %Run{} = updated_run} = Execution.update_run_heartbeat(run)
      assert DateTime.diff(updated_run.last_heartbeat_at, run.last_heartbeat_at) > 0
    end
  end

  describe "upsert_run_step/2" do
    setup do
      %{run: insert!(:run, last_heartbeat_at: DateTime.utc_now())}
    end

    test "inserts new steps", %{run: run} do
      step = build(:step)
      Execution.upsert_run_step(step, %{run_id: run.id, status: :pending})
    end

    test "updates existing steps", %{run: run} do
      %{id: step_id} = step = insert!(:step, run_id: run.id, status: :pending)

      {:ok, updated_step} = Execution.upsert_run_step(step, %{status: :running})

      assert %Step{id: ^step_id} = step
      assert updated_step.status == :running
    end

    test "step ids are unique", %{run: run} do
      step_params = %{run_id: run.id, step_id: "step-1", status: :pending}
      run_id = step_params.run_id
      step_id = step_params.step_id
      query = from s in Step, where: [run_id: ^run_id, step_id: ^step_id]
      insert!(:step, step_params)

      assert {:ok, %{id: updated_id}} = Execution.upsert_run_step(%Step{}, step_params)
      assert [%Step{id: ^updated_id}] = Repo.all(query)
    end
  end

  describe "complete_run/2" do
    setup do
      %{run: insert!(:run, status: :running, completed_at: nil)}
    end

    test "updates run status", %{run: run} do
      {:ok, completed_run} = Execution.complete_run(run, :completed)
      assert completed_run.status == :completed
    end

    test "sets completed_at", %{run: run} do
      {:ok, completed_run} = Execution.complete_run(run, :completed)
      assert %DateTime{} = completed_run.completed_at
    end
  end

  describe "update_run/2" do
    setup do
      %{run: insert!(:run)}
    end

    test "updates run with valid params", %{run: run} do
      {:ok, updated_run} = Execution.update_run(run, %{status: :suspended})
      assert updated_run.status == :suspended
    end

    test "returns changeset for invalid params", %{run: run} do
      {:error, changeset} = Execution.update_run(run, %{status: :invalid})
      assert "is invalid" in errors_on(changeset).status
    end
  end

  describe "reap_stale_runs/1" do
    setup do
      active_run = insert!(:run, status: :running, last_heartbeat_at: DateTime.utc_now())
      %{active: active_run}
    end

    test "resets run status to pending", %{active: active} do
      stale_run_ids =
        Enum.map(1..5, fn i ->
          heartbeat =
            DateTime.utc_now()
            |> DateTime.add(-i, :minute)

          insert!(:run,
            task_id: insert!(:task).id,
            status: :running,
            last_heartbeat_at: heartbeat
          ).id
        end)

      {num_reaped, reaped} = Execution.reap_stale_runs(stale_after: 1)

      refute is_nil(reaped)

      reaped_ids = Enum.map(reaped, & &1.id)

      assert num_reaped == length(stale_run_ids)
      assert [] == Enum.reject(reaped_ids, &(&1 in stale_run_ids))
      assert [] == Enum.reject(stale_run_ids, &(&1 in reaped_ids))

      refute active.id in reaped_ids
    end

    test "clears run worker metadata", %{active: active} do
      assert {1, [reaped]} = Execution.reap_stale_runs(stale_after: 0)
      assert reaped.status == :pending
      assert reaped.attempts > active.attempts
      assert is_nil(reaped.worker_id)
      assert is_nil(reaped.last_heartbeat_at)
    end

    test "does not update non-stale runs", %{active: active} do
      assert DateTime.diff(DateTime.utc_now(), active.last_heartbeat_at, :minute) < 1
      assert {0, []} = Execution.reap_stale_runs(stale_after: 1)
    end
  end
end
