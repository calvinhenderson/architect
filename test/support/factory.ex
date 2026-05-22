defmodule Architect.Factory do
  alias Architect.Repo

  ## Factories

  def build(:blueprint),
    do: %{
      "id" => "testing.blueprint.#{System.unique_integer()}",
      "steps" => []
    }

  def build(:run),
    do: %Architect.Schema.Run{
      status: :pending,
      attempts: 0,
      trigger: :manual,
      task_id: insert!(:task).id
    }

  def build(:step),
    do: %Architect.Schema.Step{
      status: :pending,
      step_id: "step-#{System.unique_integer()}",
      run_id: insert!(:run).id
    }

  def build(:task),
    do: %Architect.Schema.Task{
      name: "Task #{System.unique_integer()}",
      blueprint: build(:blueprint)
    }

  def build(:trigger),
    do: %Architect.Schema.Trigger{
      type: :manual
    }

  ## Convenience API

  def build(factory_name, attrs) do
    factory_name |> build() |> struct!(attrs)
  end

  def insert!(factory_name, attrs \\ []) do
    factory_name |> build(attrs) |> Repo.insert!()
  end
end
