defmodule Architect.Blueprints.EvaluatorTest do
  use Architect.DataCase

  import Architect.Blueprints

  @valid_blueprint_params %{
    "id" => "blueprint_evaluation",
    "namespace" => "testing",
    "tasks" => []
  }

  @invalid_blueprint_params %{}

  describe "evaluate/2" do
    test "validates the blueprint" do
      assert {:error, :validate_schema_data, errors} =
               evaluate_blueprint(@invalid_blueprint_params)

      assert {"Required properties id, namespace, tasks were not present.", "#"} in errors
    end

    test "returns a validated blueprint" do
      params = @valid_blueprint_params
      assert {:ok, ^params} = evaluate_blueprint(params)
    end
  end
end
