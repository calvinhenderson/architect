defmodule Architect.Blueprints do
  @moduledoc """
  Provides an API for interacting with blueprints.
  """

  import Architect.Schemas, only: [validate_data: 2]

  @type blueprint :: binary() | map()

  @doc "Evaluates Blueprint YAML definitions"
  @spec evaluate_blueprint(blueprint(), keyword()) ::
          {:ok, blueprint()} | {:error, atom(), term()}
  def evaluate_blueprint(blueprint, opts \\ [])

  def evaluate_blueprint(blueprint, opts) when is_binary(blueprint) do
    blueprint
    |> Architect.Documents.load_yaml(opts)
    |> List.first(%{})
    |> evaluate_blueprint(opts)
  end

  def evaluate_blueprint(blueprint, _opts) do
    case validate_data("schemas/blueprint", blueprint) do
      {:ok, validated} -> {:ok, validated}
      {:error, reason, term} -> {:error, reason, term}
    end
  end
end
