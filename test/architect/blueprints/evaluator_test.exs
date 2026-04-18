defmodule Architect.Blueprints.EvaluatorTest do
  use Architect.DataCase

  import Architect.Blueprints.Evaluator

  describe "evaluate/2" do
    test "validates the blueprint" do
      assert {:ok, %{}} = evaluate_blueprint(%{})
    end
  end
end
