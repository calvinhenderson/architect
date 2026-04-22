defmodule Architect.Blueprints do
  @moduledoc """
  """

  import Architect.Schemas, only: [validate_data: 2]

  @type blueprint :: map()

  @doc "Evaluates Blueprint YAML definitions"
  @spec evaluate_blueprint(blueprint(), keyword()) ::
          {:ok, blueprint()} | {:error, atom(), term()}
  def evaluate_blueprint(blueprint, _opts \\ []) do
    case validate_data("schemas/blueprint", blueprint) do
      {:ok, validated} -> {:ok, validated}
      {:error, reason, term} -> {:error, reason, term}
    end
  end
end
