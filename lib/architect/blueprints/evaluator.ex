defmodule Architect.Blueprints.Evaluator do
  @moduledoc "Evaluates Blueprint YAML definitions"

  alias Architect.Blueprints.Blueprint
  import Architect.Schemas, only: [validate_data: 2]

  @spec evaluate_blueprint(map(), keyword()) :: {:ok, Blueprint.t()} | {:error, term()}
  def evaluate_blueprint(blueprint, _opts \\ []) when is_map(blueprint) do
    validate_data(
      %{
        "$id" => "schemas/blueprint",
        "$schema" => "http://json-schema.org/draft-07/schema#",
        "type" => "object"
      },
      blueprint
    )
  end
end
