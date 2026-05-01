defmodule Architect.Blueprints.EvaluatorTest do
  use Architect.DataCase

  import Architect.Blueprints

  @valid_blueprint_params %{
    "id" => "testing.blueprint_evaluation",
    "steps" => [
      %{
        "id" => "step_1",
        "type" => "tests.echo"
      }
    ]
  }

  @invalid_blueprint_params %{}

  describe "evaluate/2" do
    test "validates the blueprint" do
      assert {:error, :validate_schema_data, errors} =
               evaluate_blueprint(@invalid_blueprint_params)

      assert {"Required properties id, steps were not present.", "#"} in errors
    end

    test "evaluates valid yaml document" do
      params = @valid_blueprint_params
      assert {:ok, ^params} = evaluate_blueprint(params)
    end

    test "evalulates a valid yaml blueprint" do
      params = @valid_blueprint_params

      valid_document = """
      id: testing.blueprint_evaluation
      steps:
      - id: step_1
        type: tests.echo
      """

      assert {:ok, ^params} = evaluate_blueprint(valid_document)
    end

    test "returns schema errors for invalid yaml document" do
      invalid_document = """
      ---
      invalid: invalid
      """

      assert {:error, :validate_schema_data, errors} =
               invalid_document
               |> evaluate_blueprint()

      assert {"Schema does not allow additional properties.", "#/invalid"} in errors
    end
  end
end
