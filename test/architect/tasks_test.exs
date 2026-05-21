defmodule Architect.TasksTest do
  use Architect.DataCase

  alias Architect.Tasks
  alias Architect.Schema.Task

  describe "list_tasks/1" do
    setup do
      %{
        enabled: [name: "Enabled task", enabled_at: DateTime.utc_now(), deleted_at: nil],
        disabled: [name: "Disabled task", enabled_at: nil, deleted_at: nil],
        deleted: [name: "Deleted task", enabled_at: nil, deleted_at: DateTime.utc_now()]
      }
      |> Enum.map(fn {k, v} -> {k, task_fixture(v)} end)
    end

    test "lists all results", tasks do
      results =
        [
          tasks.enabled,
          tasks.disabled
        ]
        |> Enum.sort_by(& &1.name)

      assert ^results = Tasks.list_tasks()
    end

    test "does not include deleted tasks by default", tasks do
      results = Tasks.list_tasks()

      refute tasks.deleted in results
    end

    test "excludes enabled tasks when specified", tasks do
      results = Tasks.list_tasks(enabled: false)

      refute tasks.enabled in results
    end

    test "includes deleted tasks when specified", tasks do
      results = Tasks.list_tasks(deleted: true)

      assert tasks.deleted in results
    end
  end

  describe "get_task!/1" do
    setup do
      %{task: task_fixture()}
    end

    test "gets a single task", %{task: task} do
      task = Tasks.get_task!(task.id)

      assert %Task{} = task
    end

    test "raises on no results" do
      invalid_task_id = Ecto.UUID.autogenerate()

      assert_raise Ecto.NoResultsError, fn ->
        Tasks.get_task!(invalid_task_id)
      end
    end
  end

  describe "get_task/1" do
    setup do
      %{task: task_fixture()}
    end

    test "gets a single task", %{task: task} do
      task = Tasks.get_task(task.id)

      assert %Task{} = task
    end

    test "returns nil on no results" do
      invalid_task_id = Ecto.UUID.autogenerate()
      task = Tasks.get_task(invalid_task_id)

      assert is_nil(task)
    end
  end

  describe "create_changeset/2" do
    test "returns a changeset" do
      params = valid_task_params()
      assert %Ecto.Changeset{} = Tasks.create_changeset(%Task{}, params)
    end
  end

  describe "create_task/2" do
    test "creates a task with valid params" do
      params = valid_task_params()
      assert {:ok, %Task{}} = Tasks.create_task(%Task{}, params)
    end

    test "invalid params returns a changeset with errors" do
      params = %{}

      assert {:error, changeset} = Tasks.create_task(%Task{}, params)
      assert "can't be blank" in errors_on(changeset).name
    end

    test "validates blueprints"
  end

  describe "update_changeset/2" do
    test "returns a changeset" do
      params = valid_task_params()
      assert %Ecto.Changeset{} = Tasks.update_changeset(%Task{}, params)
    end
  end

  describe "update_task/2" do
    test "updates a task with valid params" do
      task = task_fixture()
      params = valid_task_params(name: "Updated task")

      assert {:ok, %Task{name: "Updated task"}} =
               Tasks.update_task(task, params)
    end

    test "invalid params returns a changeset with errors" do
      task = task_fixture()
      params = %{name: nil, blueprint: nil}

      assert {:error, changeset} = Tasks.update_task(task, params)
      assert "can't be blank" in errors_on(changeset).name
    end

    test "validates blueprints"
  end

  describe "enable_task/1" do
    test "enables a task" do
      task = task_fixture()

      assert {:ok, %Task{enabled_at: enabled}} = Tasks.enable_task(task)
      assert %DateTime{} = enabled
    end
  end

  describe "disable_task/1" do
    setup do
      {:ok, enabled_task} =
        task_fixture()
        |> Tasks.enable_task()

      %{task: enabled_task}
    end

    test "disables a task", %{task: task} do
      assert {:ok, %Task{enabled_at: enabled}} = Tasks.disable_task(task)
      assert is_nil(enabled)
    end
  end

  describe "delete_task/1" do
    setup do
      %{task: task_fixture()}
    end

    test "deletes a task", %{task: task} do
      assert {:ok, %Task{deleted_at: deleted}} = Tasks.delete_task(task)
      assert %DateTime{} = deleted
    end
  end

  defp valid_task_params(opts \\ []) do
    params = Enum.into(opts, %{})
    id = :rand.uniform(999)

    {:ok, blueprint} =
      """
      id: blueprint-#{id}
      steps: []
      """
      |> Architect.Blueprints.evaluate_blueprint()

    %{
      name: "Task #{id}",
      blueprint: blueprint
    }
    |> Map.merge(params)
  end

  defp task_fixture(opts \\ []) do
    create_params = valid_task_params(opts)
    {:ok, task} = Tasks.create_task(%Task{}, create_params)
    task
  end
end
